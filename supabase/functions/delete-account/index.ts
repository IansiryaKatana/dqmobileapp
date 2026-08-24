// Deletes the authenticated user's Auth record after scrubbing leftover PII.
// Requires the caller's user JWT (not the anon key).
//
// Deploy: supabase functions deploy delete-account

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

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

  const auth = req.headers.get("Authorization");
  const url = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const anon = Deno.env.get("SUPABASE_ANON_KEY");
  if (!auth?.startsWith("Bearer ") || !url || !serviceKey || !anon) {
    return json({ error: "Not signed in" }, 401);
  }

  const userClient = createClient(url, anon, {
    global: { headers: { Authorization: auth } },
  });
  const { data: userData, error: userError } = await userClient.auth.getUser();
  const userId = userData.user?.id;
  if (userError || !userId) {
    return json({ error: "Not signed in" }, 401);
  }

  const admin = createClient(url, serviceKey);

  await admin.from("orders").update({ address: null }).eq("user_id", userId);
  await admin
    .from("scholar_questions")
    .update({ name: "Deleted user", email: "deleted@donatequran.com" })
    .eq("user_id", userId);
  await admin.from("donations").update({ metadata: {} }).eq("user_id", userId);

  const { error: deleteError } = await admin.auth.admin.deleteUser(userId);
  if (deleteError) {
    console.error("deleteUser failed", deleteError);
    return json({ error: "Could not delete the account" }, 500);
  }

  return json({ deleted: true });
});
