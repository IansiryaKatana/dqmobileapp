/** PayPal REST helpers for postage checkout.
 * Secrets: PAYPAL_CLIENT_ID, PAYPAL_CLIENT_SECRET, PAYPAL_MODE (sandbox|live)
 */

export const PAYPAL_RETURN_URL = "https://donatequran.com/paypal-return";
export const PAYPAL_CANCEL_URL = "https://donatequran.com/paypal-cancel";

export function paypalApiBase(): string {
  const mode = (Deno.env.get("PAYPAL_MODE") ?? "sandbox").trim().toLowerCase();
  return mode === "live" ? "https://api-m.paypal.com" : "https://api-m.sandbox.paypal.com";
}

export function penceToPaypalAmount(pence: number): string {
  if (!Number.isInteger(pence) || pence < 0) {
    throw new Error("Invalid pence amount");
  }
  return (pence / 100).toFixed(2);
}

export function paypalAmountToPence(value: string): number {
  const n = Number(value);
  if (!Number.isFinite(n)) return NaN;
  return Math.round(n * 100);
}

export function paypalCredentialsConfigured(): boolean {
  const id = Deno.env.get("PAYPAL_CLIENT_ID")?.trim();
  const secret = Deno.env.get("PAYPAL_CLIENT_SECRET")?.trim();
  return Boolean(id && secret);
}

export async function paypalAccessToken(): Promise<string> {
  const id = Deno.env.get("PAYPAL_CLIENT_ID")?.trim();
  const secret = Deno.env.get("PAYPAL_CLIENT_SECRET")?.trim();
  if (!id || !secret) {
    throw new Error("PayPal is not configured");
  }
  const creds = btoa(`${id}:${secret}`);
  const res = await fetch(`${paypalApiBase()}/v1/oauth2/token`, {
    method: "POST",
    headers: {
      Authorization: `Basic ${creds}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: "grant_type=client_credentials",
  });
  const body = await res.json();
  if (!res.ok || typeof body.access_token !== "string") {
    console.error("PayPal token failed", body);
    throw new Error("PayPal token failed");
  }
  return body.access_token;
}

export async function paypalFetch(path: string, init: RequestInit = {}): Promise<Response> {
  const token = await paypalAccessToken();
  const headers = new Headers(init.headers);
  headers.set("Authorization", `Bearer ${token}`);
  if (!headers.has("Content-Type")) {
    headers.set("Content-Type", "application/json");
  }
  return fetch(`${paypalApiBase()}${path}`, { ...init, headers });
}

export function approvalUrlFromOrder(order: {
  links?: Array<{ rel?: string; href?: string }>;
}): string | null {
  const links = order.links ?? [];
  const match = links.find((l) => l.rel === "payer-action") ??
    links.find((l) => l.rel === "approve");
  return match?.href ?? null;
}

export function capturedGbpPence(order: {
  purchase_units?: Array<{
    payments?: {
      captures?: Array<{
        status?: string;
        amount?: { value?: string; currency_code?: string };
      }>;
    };
  }>;
}): { pence: number; currency: string } | null {
  const capture = order.purchase_units?.[0]?.payments?.captures?.[0];
  const value = capture?.amount?.value;
  const currency = capture?.amount?.currency_code?.toLowerCase() ?? "";
  if (!value) return null;
  const pence = paypalAmountToPence(value);
  if (!Number.isFinite(pence)) return null;
  return { pence, currency };
}
