-- One App Media image slot per Wudu guide step.
INSERT INTO public.app_page_media (page_key, slot_key, label, description, media_type, fallback_asset, sort_order)
VALUES
  ('wudu', 'bismillah', 'Step 1 · Bismillah', 'Intention / opening', 'image', 'assets/images/wudu_bismillah.png', 1),
  ('wudu', 'hands', 'Step 2 · Hands', 'Wash both hands', 'image', NULL, 2),
  ('wudu', 'mouth', 'Step 3 · Mouth', 'Rinse the mouth', 'image', NULL, 3),
  ('wudu', 'nose', 'Step 4 · Nose', 'Rinse the nostrils', 'image', NULL, 4),
  ('wudu', 'face', 'Step 5 · Face', 'Wash the full face', 'image', NULL, 5),
  ('wudu', 'arms', 'Step 6 · Arms', 'Wash to the elbows', 'image', NULL, 6),
  ('wudu', 'head', 'Step 7 · Head', 'Wipe the head', 'image', NULL, 7),
  ('wudu', 'ears', 'Step 8 · Ears', 'Wipe both ears', 'image', NULL, 8),
  ('wudu', 'feet', 'Step 9 · Feet', 'Wash to the ankles', 'image', NULL, 9),
  ('wudu', 'closing', 'Step 10 · Closing duʿā', 'Closing invocation', 'image', NULL, 10)
ON CONFLICT (page_key, slot_key) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  media_type = EXCLUDED.media_type,
  fallback_asset = COALESCE(public.app_page_media.fallback_asset, EXCLUDED.fallback_asset),
  sort_order = EXCLUDED.sort_order,
  updated_at = now();
