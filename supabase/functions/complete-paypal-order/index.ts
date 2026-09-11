// Captures a PayPal Checkout order, then inserts the Quran order.
// Uses the service role so guest orders (user_id null) are allowed.
//
// Secrets:
//   PAYPAL_CLIENT_ID
//   PAYPAL_CLIENT_SECRET
//   PAYPAL_MODE (sandbox | live)
//   SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY (provided by the runtime)
//
// Deploy: supabase functions deploy complete-paypal-order

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { parsePackKind, quoteOrder } from "../_shared/order_pricing.ts";
import {
  capturedGbpPence,
  paypalCredentialsConfigured,
  paypalFetch,
} from "../_shared/paypal.ts";

type OrderBody = {
  paypal_order_id?: string;
  title?: string;
  kind?: string;
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

function parseCustomId(customId: unknown): { kind: string; quantity: number } | null {
  if (typeof customId !== "string") return null;
  const [kind, qty] = customId.split(":");
  const quantity = Number(qty);
  if (!kind || !Number.isInteger(quantity)) return null;
  return { kind, quantity };
}

async function loadCapturedOrder(orderId: string): Promise<Record<string, unknown> | null> {
  const captureRes = await paypalFetch(`/v2/checkout/orders/${encodeURIComponent(orderId)}/capture`, {
    method: "POST",
    headers: { Prefer: "return=representation" },
  });
  const captureBody = await captureRes.json();
  if (captureRes.ok) return captureBody as Record<string, unknown>;

  const alreadyCaptured = captureRes.status === 422 &&
    JSON.stringify(captureBody).includes("ORDER_ALREADY_CAPTURED");
  if (!alreadyCaptured) {
    console.error("PayPal capture failed", captureBody);
    return null;
  }

  const getRes = await paypalFetch(`/v2/checkout/orders/${encodeURIComponent(orderId)}`);
  const getBody = await getRes.json();
  if (!getRes.ok) {
    console.error("PayPal order fetch failed", getBody);
    return null;
  }
  return getBody as Record<string, unknown>;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204 });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!paypalCredentialsConfigured() || !supabaseUrl || !serviceKey) {
    return json({ error: "Postage payments are not configured" }, 503);
  }

  let body: OrderBody;
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  const paypalOrderId = body.paypal_order_id?.trim();
  const title = body.title?.trim() || "Quran";
  const language = body.language?.trim() || "English";
  const line1 = body.address?.line1?.trim() ?? "";
  const city = body.address?.city?.trim() ?? "";
  const postcode = body.address?.postcode?.trim() ?? "";

  if (!paypalOrderId || !line1 || !city || !postcode) {
    return json({ error: "Missing payment or address details" }, 400);
  }

  const paypalOrder = await loadCapturedOrder(paypalOrderId);
  if (!paypalOrder) {
    return json({ error: "Could not verify postage payment" }, 502);
  }
  if (paypalOrder.status !== "COMPLETED") {
    return json({ error: "Postage payment is not complete" }, 402);
  }

  const customId = (paypalOrder.purchase_units as Array<{ custom_id?: string }> | undefined)
    ?.[0]?.custom_id;
  const fromPaypal = parseCustomId(customId);
  const kind = parsePackKind(body.kind) ?? parsePackKind(fromPaypal?.kind);
  const quantity = Number(body.quantity ?? fromPaypal?.quantity);
  const quote = kind ? quoteOrder(kind, quantity) : null;
  if (!quote) {
    return json({ error: "Invalid order quantity" }, 400);
  }
  if (quote.quranCount < 1 || quote.quranCount > 150) {
    return json({ error: "Invalid quantity" }, 400);
  }

  const captured = capturedGbpPence(paypalOrder as {
    purchase_units?: Array<{
      payments?: {
        captures?: Array<{
          status?: string;
          amount?: { value?: string; currency_code?: string };
        }>;
      };
    }>;
  });
  if (!captured || captured.pence !== quote.totalPence || captured.currency !== "gbp") {
    return json({ error: "Payment amount does not match order total" }, 400);
  }

  const supabase = createClient(supabaseUrl, serviceKey);
  const { data: existing } = await supabase
    .from("orders")
    .select("reference")
    .eq("paypal_order_id", paypalOrderId)
    .maybeSingle();
  if (existing?.reference) {
    return json({ reference: existing.reference, idempotent: true });
  }

  const userId = await userIdFromRequest(req);
  const reference = `DQ-ORD-${Date.now()}`;
  const { error } = await supabase.from("orders").insert({
    user_id: userId,
    reference,
    quantity: quote.quranCount,
    language,
    status: "paid",
    cost_pence: quote.costPence,
    postage_pence: quote.postagePence,
    paypal_order_id: paypalOrderId,
    payment_provider: "paypal",
    address: {
      line1,
      city,
      postcode,
      title,
      pack_kind: quote.kind,
      pack_quantity: quote.quantity,
    },
  });

  if (error) {
    if (error.code === "23505") {
      const { data: raced } = await supabase
        .from("orders")
        .select("reference")
        .eq("paypal_order_id", paypalOrderId)
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
