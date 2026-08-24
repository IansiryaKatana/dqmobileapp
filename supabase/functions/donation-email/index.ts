// Donation confirmation email via Resend.
//
// Secrets (Supabase Dashboard → Edge Functions → Secrets):
//   RESEND_API_KEY          — required
//   DONATION_EMAIL_FROM     — optional, e.g. "Donate Quran <onboarding@resend.dev>"
//
// Triggers:
// 1. Flutter invokes after a completed donation (primary).
// 2. Optional Database Webhook on public.donations INSERT (payload: { record: {...} }).
//
// Deploy: supabase functions deploy donation-email

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

type DonationPayload = {
  receipt_id?: string;
  amount_pence?: number;
  currency?: string;
  email?: string;
  donor_name?: string;
  status?: string;
  // Database Webhook shape
  record?: {
    receipt_id?: string | null;
    amount_pence?: number;
    currency?: string;
    status?: string;
    metadata?: {
      donor_email?: string;
      donor_name?: string;
    } | null;
  };
  type?: string;
};

function pickPayload(body: DonationPayload) {
  const record = body.record;
  const email =
    body.email?.trim() ||
    record?.metadata?.donor_email?.trim() ||
    "";
  const donorName =
    body.donor_name?.trim() ||
    record?.metadata?.donor_name?.trim() ||
    "";
  const receiptId = body.receipt_id || record?.receipt_id || "";
  const amountPence = body.amount_pence ?? record?.amount_pence ?? 0;
  const currency = (body.currency || record?.currency || "GBP").toUpperCase();
  const status = body.status || record?.status || "";
  return { email, donorName, receiptId, amountPence, currency, status };
}

function formatAmount(amountPence: number, currency: string) {
  const amount = (amountPence / 100).toFixed(2);
  if (currency === "GBP") return `£${amount}`;
  return `${amount} ${currency}`;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const apiKey = Deno.env.get("RESEND_API_KEY");
  if (!apiKey) {
    return new Response(
      JSON.stringify({ ok: false, message: "RESEND_API_KEY is not configured" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }

  const body = (await req.json().catch(() => ({}))) as DonationPayload;
  const { email, donorName, receiptId, amountPence, currency, status } =
    pickPayload(body);

  if (status && status !== "completed") {
    return new Response(
      JSON.stringify({ ok: true, skipped: true, reason: "status_not_completed" }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  }

  if (!email || !email.includes("@")) {
    return new Response(
      JSON.stringify({ ok: true, skipped: true, reason: "missing_email" }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  }

  const from =
    Deno.env.get("DONATION_EMAIL_FROM") ??
    "Donate Quran <onboarding@resend.dev>";
  const amountLabel = formatAmount(amountPence, currency);
  const greeting = donorName ? `Assalamu alaikum ${donorName},` : "Assalamu alaikum,";

  // Optional CMS templates from app_settings.donation_email_copy
  let subjectTemplate = "Donation receipt {{receipt_id}}";
  let intro =
    "Your gift of {{amount}} helps print and distribute Qurans.";
  let footer = "Donations fund Quran printing. Store processing fees may apply; the remainder goes to printing.";
  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    if (supabaseUrl && serviceKey) {
      const { createClient } = await import("jsr:@supabase/supabase-js@2");
      const admin = createClient(supabaseUrl, serviceKey);
      const { data: row } = await admin
        .from("app_settings")
        .select("value")
        .eq("key", "donation_email_copy")
        .maybeSingle();
      const v = row?.value as Record<string, string> | undefined;
      if (v?.subject_template?.trim()) subjectTemplate = v.subject_template.trim();
      if (v?.intro?.trim()) intro = v.intro.trim();
      if (v?.footer?.trim()) footer = v.footer.trim();
    }
  } catch (e) {
    console.warn("donation_email_copy settings fetch failed", e);
  }

  const apply = (tpl: string) =>
    tpl
      .replaceAll("{{receipt_id}}", receiptId || "")
      .replaceAll("{{amount}}", amountLabel)
      .replaceAll("{{donor_name}}", donorName || "");

  const subject = apply(subjectTemplate).trim() || `Donation receipt ${receiptId || ""}`.trim();
  const introHtml = apply(intro).replace(
    amountLabel,
    `<strong>${amountLabel}</strong>`,
  );
  const html = `
    <div style="font-family: system-ui, sans-serif; max-width: 520px; margin: 0 auto; color: #1c1917;">
      <h1 style="font-size: 20px;">Thank you for your donation</h1>
      <p>${greeting}</p>
      <p>${introHtml}</p>
      <p style="background:#faf6f0;padding:12px 16px;border-radius:8px;">
        Receipt: <strong>${receiptId || "—"}</strong>
      </p>
      <p style="color:#78716c;font-size:13px;">${apply(footer)}</p>
      <p>— Donate Quran</p>
    </div>
  `;

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from,
      to: [email],
      subject,
      html,
    }),
  });

  const result = await res.json().catch(() => ({}));
  if (!res.ok) {
    console.error("Resend error", result);
    return new Response(
      JSON.stringify({ ok: false, message: "Failed to send email", detail: result }),
      { status: 502, headers: { "Content-Type": "application/json" } },
    );
  }

  return new Response(
    JSON.stringify({ ok: true, id: result.id }),
    { status: 200, headers: { "Content-Type": "application/json" } },
  );
});
