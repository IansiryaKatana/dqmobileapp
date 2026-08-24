-- Qualify donation copy so store listings are not misleading about IAP fees.

UPDATE public.faq_items
SET answer = 'Donations fund Quran printing and distribution. If you pay through the App Store or Play Store, those stores may deduct a processing fee; the remainder goes to printing.'
WHERE question = 'Where does my donation go?';

UPDATE public.app_settings
SET value = jsonb_set(
  COALESCE(value, '{}'::jsonb),
  '{tagline}',
  '"Donations fund Quran printing. App Store and Play Store processing fees may apply; the remainder goes to printing."'
)
WHERE key = 'donate_copy';

UPDATE public.app_settings
SET value = jsonb_set(
  COALESCE(value, '{}'::jsonb),
  '{footer}',
  '"Donations fund Quran printing. Store processing fees may apply; the remainder goes to printing."'
)
WHERE key = 'donation_email_copy';
