// Creates a Stripe PaymentIntent for a Quran order (Cost + Postage).
// Amount is looked up server-side — the client cannot set it.
//
// Secrets (Supabase Dashboard → Edge Functions → Secrets):
//   STRIPE_SECRET_KEY
//
// Deploy: supabase functions deploy create-postage-payment

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { parsePackKind, quoteOrder } from "../_shared/order_pricing.ts";

const CURRENCY = "gbp";

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204 });
  }
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const stripeKey = Deno.env.get("STRIPE_SECRET_KEY")?.trim();
  if (!stripeKey) {
    return json({ error: "Postage payments are not configured" }, 503);
  }

  let body: { kind?: unknown; quantity?: unknown } = {};
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  const kind = parsePackKind(body.kind);
  const quantity = Number(body.quantity);
  const quote = kind ? quoteOrder(kind, quantity) : null;
  if (!quote) {
    return json({ error: "Invalid order quantity" }, 400);
  }

  const params = new URLSearchParams({
    amount: String(quote.totalPence),
    currency: CURRENCY,
    "automatic_payment_methods[enabled]": "true",
    "metadata[purpose]": "quran_order",
    "metadata[kind]": quote.kind,
    "metadata[quantity]": String(quote.quantity),
    "metadata[quran_count]": String(quote.quranCount),
    "metadata[cost_pence]": String(quote.costPence),
    "metadata[postage_pence]": String(quote.postagePence),
  });

  const stripeRes = await fetch("https://api.stripe.com/v1/payment_intents", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${stripeKey}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: params,
  });

  const stripeBody = await stripeRes.json();
  if (!stripeRes.ok) {
    console.error("Stripe PaymentIntent create failed", stripeBody);
    return json({ error: "Could not start postage payment" }, 502);
  }

  return json({
    client_secret: stripeBody.client_secret,
    payment_intent_id: stripeBody.id,
    amount_pence: quote.totalPence,
    cost_pence: quote.costPence,
    postage_pence: quote.postagePence,
    currency: CURRENCY,
  });
});
