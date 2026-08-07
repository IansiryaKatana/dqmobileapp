-- Optional helper: invoke donation-email after completed donations.
-- Primary path is Flutter `functions.invoke` after checkout.
-- Configure a Database Webhook in the Supabase dashboard if you prefer:
--   Table: public.donations, Events: INSERT, URL: /functions/v1/donation-email
--   (payload includes `record` with metadata.donor_email)

COMMENT ON TABLE public.donations IS
  'Donations. Confirmation emails: Edge Function donation-email (Resend). Set RESEND_API_KEY secret.';
