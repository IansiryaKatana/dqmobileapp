-- CMS slot for splash / onboarding full-bleed background.
INSERT INTO public.app_page_media (page_key, slot_key, label, description, media_type, fallback_asset, sort_order)
VALUES (
  'onboarding',
  'background',
  'Onboarding background',
  'Full-bleed background on splash and onboarding',
  'image',
  'assets/images/donate_quran_bg.png',
  0
)
ON CONFLICT (page_key, slot_key) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  media_type = EXCLUDED.media_type,
  fallback_asset = COALESCE(public.app_page_media.fallback_asset, EXCLUDED.fallback_asset),
  sort_order = EXCLUDED.sort_order,
  updated_at = now();
