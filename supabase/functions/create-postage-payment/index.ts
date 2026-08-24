// Creates a Stripe PaymentIntent for Quran postage.
// Amount is server-fixed — the client cannot change it.
//
// Secrets (Supabase Dashboard → Edge Functions → Secrets):
//   STRIPE_SECRET_KEY
//
// Deploy: supabase functions deploy create-postage-payment

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const POSTAGE_PENCE = 399;
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

  const params = new URLSearchParams({
    amount: String(POSTAGE_PENCE),
    currency: CURRENCY,
    "automatic_payment_methods[enabled]": "true",
    "metadata[purpose]": "quran_postage",
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
    amount_pence: POSTAGE_PENCE,
    currency: CURRENCY,
  });
});
