# Supabase Edge Function — RevenueCat webhook handler
# Deploy: supabase functions deploy revenuecat-webhook

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const body = await req.json();
  const event = body.event;
  const appUserId = event?.app_user_id;

  if (appUserId && event?.type === "INITIAL_PURCHASE") {
    await supabase.from("donations").insert({
      user_id: appUserId,
      amount_pence: 0,
      status: "subscription_active",
      receipt_id: event.transaction_id,
    });
  }

  return new Response(JSON.stringify({ received: true }), {
    headers: { "Content-Type": "application/json" },
  });
});
