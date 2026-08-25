-- Title case for hub hero; header background slots for Umrah & Hajj guides.

UPDATE public.app_settings
SET
  value = jsonb_set(value, '{title}', '"Umrah & Hajj Guide"'),
  updated_at = now()
WHERE key = 'pilgrimage_hub';

INSERT INTO public.app_page_media (page_key, slot_key, label, description, media_type, fallback_asset, sort_order)
VALUES
  (
    'umrah',
    'header',
    'Guide header background',
    'Full-width image behind the Umrah guide header',
    'image',
    NULL,
    0
  ),
  (
    'hajj',
    'header',
    'Guide header background',
    'Full-width image behind the Hajj guide header',
    'image',
    NULL,
    0
  )
ON CONFLICT (page_key, slot_key) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  media_type = EXCLUDED.media_type,
  sort_order = EXCLUDED.sort_order,
  updated_at = now();
