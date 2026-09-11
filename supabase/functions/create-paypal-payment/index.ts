// Creates a PayPal Checkout order for a Quran order (Cost + Postage).
// Amount is looked up server-side — the client cannot set it.
//
// Secrets (Supabase Dashboard → Edge Functions → Secrets):
//   PAYPAL_CLIENT_ID
//   PAYPAL_CLIENT_SECRET
//   PAYPAL_MODE (sandbox | live)
//
// Deploy: supabase functions deploy create-paypal-payment

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { parsePackKind, quoteOrder } from "../_shared/order_pricing.ts";
import {
  PAYPAL_CANCEL_URL,
  PAYPAL_RETURN_URL,
  approvalUrlFromOrder,
  penceToPaypalAmount,
  paypalCredentialsConfigured,
  paypalFetch,
} from "../_shared/paypal.ts";

const CURRENCY = "GBP";

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

  if (!paypalCredentialsConfigured()) {
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

  const paypalRes = await paypalFetch("/v2/checkout/orders", {
    method: "POST",
    body: JSON.stringify({
      intent: "CAPTURE",
      purchase_units: [
        {
          custom_id: `${quote.kind}:${quote.quantity}`,
          description: "Quran order (cost + postage)",
          amount: {
            currency_code: CURRENCY,
            value: penceToPaypalAmount(quote.totalPence),
          },
        },
      ],
      application_context: {
        brand_name: "Donate Quran",
        landing_page: "NO_PREFERENCE",
        user_action: "PAY_NOW",
        shipping_preference: "NO_SHIPPING",
        return_url: PAYPAL_RETURN_URL,
        cancel_url: PAYPAL_CANCEL_URL,
      },
    }),
  });

  const paypalBody = await paypalRes.json();
  if (!paypalRes.ok) {
    console.error("PayPal order create failed", paypalBody);
    return json({ error: "Could not start postage payment" }, 502);
  }

  const orderId = paypalBody.id as string | undefined;
  const approvalUrl = approvalUrlFromOrder(paypalBody);
  if (!orderId || !approvalUrl) {
    console.error("PayPal order missing id or approval url", paypalBody);
    return json({ error: "Could not start postage payment" }, 502);
  }

  return json({
    order_id: orderId,
    approval_url: approvalUrl,
    amount_pence: quote.totalPence,
    cost_pence: quote.costPence,
    postage_pence: quote.postagePence,
    currency: CURRENCY.toLowerCase(),
  });
});
