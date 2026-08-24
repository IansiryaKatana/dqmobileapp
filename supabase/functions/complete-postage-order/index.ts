// Verifies a succeeded Stripe PaymentIntent, then inserts the Quran order.
// Uses the service role so guest orders (user_id null) are allowed.
//
// Secrets:
//   STRIPE_SECRET_KEY
//   SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY (provided by the runtime)
//
// Deploy: supabase functions deploy complete-postage-order

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const POSTAGE_PENCE = 399;

type OrderBody = {
  payment_intent_id?: string;
  title?: string;
  quantity?: number;
  language?: string;
  address?: {
    line1?: string;
    city?: string;
    postcode?: string;
  };
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

async function userIdFromRequest(req: Request): Promise<string | null> {
  const auth = req.headers.get("Authorization");
  if (!auth?.startsWith("Bearer ")) return null;
  const url = Deno.env.get("SUPABASE_URL");
  const anon = Deno.env.get("SUPABASE_ANON_KEY");
  if (!url || !anon) return null;
  const userClient = createClient(url, anon, {
    global: { headers: { Authorization: auth } },
  });
  const { data } = await userClient.auth.getUser();
  return data.user?.id ?? null;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204 });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const stripeKey = Deno.env.get("STRIPE_SECRET_KEY")?.trim();
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!stripeKey || !supabaseUrl || !serviceKey) {
    return json({ error: "Postage payments are not configured" }, 503);
  }

  let body: OrderBody;
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  const paymentIntentId = body.payment_intent_id?.trim();
  const title = body.title?.trim() || "Quran";
  const quantity = Number(body.quantity) || 1;
  const language = body.language?.trim() || "English";
  const line1 = body.address?.line1?.trim() ?? "";
  const city = body.address?.city?.trim() ?? "";
  const postcode = body.address?.postcode?.trim() ?? "";

  if (!paymentIntentId || !line1 || !city || !postcode) {
    return json({ error: "Missing payment or address details" }, 400);
  }
  if (quantity < 1 || quantity > 50) {
    return json({ error: "Invalid quantity" }, 400);
  }

  const piRes = await fetch(
    `https://api.stripe.com/v1/payment_intents/${encodeURIComponent(paymentIntentId)}`,
    { headers: { Authorization: `Bearer ${stripeKey}` } },
  );
  const pi = await piRes.json();
  if (!piRes.ok) {
    return json({ error: "Could not verify postage payment" }, 502);
  }
  if (pi.status !== "succeeded") {
    return json({ error: "Postage payment is not complete" }, 402);
  }
  if (Number(pi.amount) !== POSTAGE_PENCE || pi.currency !== "gbp") {
    return json({ error: "Payment amount does not match postage" }, 400);
  }

  const supabase = createClient(supabaseUrl, serviceKey);
  const { data: existing } = await supabase
    .from("orders")
    .select("reference")
    .eq("stripe_payment_intent_id", paymentIntentId)
    .maybeSingle();
  if (existing?.reference) {
    return json({ reference: existing.reference, idempotent: true });
  }

  const userId = await userIdFromRequest(req);
  const reference = `DQ-ORD-${Date.now()}`;
  const { error } = await supabase.from("orders").insert({
    user_id: userId,
    reference,
    quantity,
    language,
    status: "paid",
    postage_pence: POSTAGE_PENCE,
    stripe_payment_intent_id: paymentIntentId,
    address: { line1, city, postcode, title },
  });

  if (error) {
    if (error.code === "23505") {
      const { data: raced } = await supabase
        .from("orders")
        .select("reference")
        .eq("stripe_payment_intent_id", paymentIntentId)
        .maybeSingle();
      if (raced?.reference) {
        return json({ reference: raced.reference, idempotent: true });
      }
    }
    console.error("Order insert failed", error);
    return json({ error: "Could not save the order" }, 500);
  }

  return json({ reference, status: "paid" });
});
