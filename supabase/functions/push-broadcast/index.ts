// Admin push broadcast via FCM HTTP v1 (service account).
//
// Secrets (Dashboard → Edge Functions → Secrets, or CLI):
//   FCM_SERVICE_ACCOUNT_JSON — full Firebase service account JSON (one line)
//   Optional: FCM_PROJECT_ID — defaults to project_id inside the JSON
//
// Auth: caller must be admin (JWT). Service role used only for device_tokens.
// Deploy: supabase functions deploy push-broadcast --project-ref mildsuuygbzgdunwmzuk

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

type Body = {
  title?: string;
  body?: string;
  deep_link?: string;
  broadcast_id?: string;
};

type ServiceAccount = {
  project_id?: string;
  client_email?: string;
  private_key?: string;
};

Deno.serve(async (req) => {
  // Browser CMS (localhost) sends OPTIONS preflight before POST.
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders(req) });
  }

  if (req.method !== "POST") {
    return json({ ok: false, message: "Method not allowed" }, 405, req);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.startsWith("Bearer ")) {
    return json({ ok: false, message: "Missing Authorization bearer token" }, 401, req);
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: userData, error: userErr } = await userClient.auth.getUser();
  if (userErr || !userData.user) {
    return json({ ok: false, message: "Invalid session" }, 401, req);
  }

  const adminClient = createClient(supabaseUrl, serviceKey);
  const { data: profile } = await adminClient
    .from("profiles")
    .select("role")
    .eq("id", userData.user.id)
    .maybeSingle();

  if (profile?.role !== "admin") {
    return json({ ok: false, message: "Admin access required" }, 403, req);
  }

  const payload = (await req.json().catch(() => ({}))) as Body;
  const title = payload.title?.trim() ?? "";
  const body = payload.body?.trim() ?? "";
  const deepLink = payload.deep_link?.trim() || "/";
  const broadcastId = payload.broadcast_id?.trim() || "";

  if (!title || !body) {
    return json({ ok: false, message: "title and body are required" }, 400);
  }

  const saRaw = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON")?.trim() ?? "";
  if (!saRaw) {
    const message =
      "FCM is not configured. Set Edge Function secret FCM_SERVICE_ACCOUNT_JSON (Firebase service account JSON). Or send from Firebase Console → Messaging.";
    await updateBroadcast(adminClient, broadcastId, {
      status: "failed",
      error_message: message,
    });
    return json({ ok: false, configured: false, message }, 503);
  }

  let serviceAccount: ServiceAccount;
  try {
    serviceAccount = JSON.parse(saRaw) as ServiceAccount;
  } catch {
    const message = "FCM_SERVICE_ACCOUNT_JSON is not valid JSON";
    await updateBroadcast(adminClient, broadcastId, {
      status: "failed",
      error_message: message,
    });
    return json({ ok: false, configured: false, message }, 503);
  }

  const projectId =
    (Deno.env.get("FCM_PROJECT_ID")?.trim() || serviceAccount.project_id || "").trim();
  if (!projectId || !serviceAccount.client_email || !serviceAccount.private_key) {
    const message =
      "Service account JSON must include project_id, client_email, and private_key";
    await updateBroadcast(adminClient, broadcastId, {
      status: "failed",
      error_message: message,
    });
    return json({ ok: false, configured: false, message }, 503);
  }

  const { data: tokens, error: tokenErr } = await adminClient
    .from("device_tokens")
    .select("token")
    .limit(500);

  if (tokenErr) {
    return json({ ok: false, message: tokenErr.message }, 500);
  }

  const list = (tokens ?? []).map((r) => r.token as string).filter(Boolean);
  if (list.length === 0) {
    await updateBroadcast(adminClient, broadcastId, {
      status: "sent",
      sent_count: 0,
      failed_count: 0,
      recipients: 0,
      sent_at: new Date().toISOString(),
      error_message: "No device tokens registered",
    });
    return json({
      ok: true,
      sent: 0,
      failed: 0,
      recipients: 0,
      broadcast_id: broadcastId || undefined,
      message: "No device tokens registered",
    });
  }

  let accessToken: string;
  try {
    accessToken = await getGoogleAccessToken(serviceAccount);
  } catch (err) {
    console.error("FCM auth error", err);
    const detail = err instanceof Error ? err.message : String(err);
    await updateBroadcast(adminClient, broadcastId, {
      status: "failed",
      error_message: `FCM auth failed: ${detail}`,
      recipients: list.length,
    });
    return json(
      {
        ok: false,
        message: "Failed to authorize with Google (check service account JSON)",
        detail,
      },
      502,
    );
  }

  let sent = 0;
  let failed = 0;
  const errors: unknown[] = [];

  // HTTP v1 sends one token per request
  for (const token of list) {
    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            token,
            notification: { title, body },
            data: { deep_link: deepLink },
          },
        }),
      },
    );

    if (res.ok) {
      sent += 1;
    } else {
      failed += 1;
      const detail = await res.json().catch(() => ({}));
      errors.push(detail);
      console.error("FCM send error", detail);
    }
  }

  const status = sent > 0 ? "sent" : "failed";
  await updateBroadcast(adminClient, broadcastId, {
    status,
    sent_count: sent,
    failed_count: failed,
    recipients: list.length,
    sent_at: new Date().toISOString(),
    error_message: failed > 0 && sent === 0
      ? "All deliveries failed"
      : failed > 0
      ? `${failed} delivery failure(s)`
      : null,
  });

  return json({
    ok: failed === 0 || sent > 0,
    sent,
    failed,
    recipients: list.length,
    broadcast_id: broadcastId || undefined,
    ...(errors.length ? { sample_errors: errors.slice(0, 3) } : {}),
  });
});

async function updateBroadcast(
  client: ReturnType<typeof createClient>,
  broadcastId: string,
  patch: Record<string, unknown>,
) {
  if (!broadcastId) return;
  await client
    .from("push_broadcasts")
    .update({ ...patch, updated_at: new Date().toISOString() })
    .eq("id", broadcastId);
}

function corsHeaders(req?: Request): HeadersInit {
  const origin = req?.headers.get("Origin") ?? "*";
  return {
    "Access-Control-Allow-Origin": origin,
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type, prefer",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Max-Age": "86400",
    Vary: "Origin",
  };
}

function json(data: unknown, status = 200, req?: Request) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders(req),
    },
  });
}

function b64url(data: ArrayBuffer | Uint8Array | string): string {
  let bytes: Uint8Array;
  if (typeof data === "string") {
    bytes = new TextEncoder().encode(data);
  } else if (data instanceof Uint8Array) {
    bytes = data;
  } else {
    bytes = new Uint8Array(data);
  }
  let bin = "";
  for (const b of bytes) bin += String.fromCharCode(b);
  return btoa(bin).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
}

async function importPrivateKey(pem: string): Promise<CryptoKey> {
  const pemContents = pem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\\n/g, "")
    .replace(/\s+/g, "");
  const binaryDer = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));
  return await crypto.subtle.importKey(
    "pkcs8",
    binaryDer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
}

async function getGoogleAccessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claim = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  const unsigned = `${b64url(JSON.stringify(header))}.${b64url(JSON.stringify(claim))}`;
  const key = await importPrivateKey(sa.private_key!);
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  const jwt = `${unsigned}.${b64url(signature)}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const tokenJson = await tokenRes.json();
  if (!tokenRes.ok || !tokenJson.access_token) {
    throw new Error(tokenJson.error_description || tokenJson.error || "token exchange failed");
  }
  return tokenJson.access_token as string;
}
