-- Structured fields for guide steps (Wudu / How to Pray rich content)
-- Keeps `body` for plain-text guides and as JSON fallback for older rows.

ALTER TABLE public.guide_steps
  ADD COLUMN IF NOT EXISTS subtitle TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS description TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS arabic TEXT,
  ADD COLUMN IF NOT EXISTS arabic_en TEXT,
  ADD COLUMN IF NOT EXISTS icon TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS icon_url TEXT,
  ADD COLUMN IF NOT EXISTS repeat_label TEXT,
  ADD COLUMN IF NOT EXISTS time_label TEXT,
  ADD COLUMN IF NOT EXISTS rakaat INTEGER,
  ADD COLUMN IF NOT EXISTS accent TEXT;

COMMENT ON COLUMN public.guide_steps.subtitle IS 'Short line under step title (e.g. Intention)';
COMMENT ON COLUMN public.guide_steps.description IS 'Main instructional text (maps from JSON desc)';
COMMENT ON COLUMN public.guide_steps.icon IS 'Material icon key, e.g. favorite_border';
COMMENT ON COLUMN public.guide_steps.icon_url IS 'Optional uploaded icon image (cms-media public URL)';
COMMENT ON COLUMN public.guide_steps.repeat_label IS 'e.g. × 3 times';

-- Backfill from JSON body where columns are still empty
UPDATE public.guide_steps s
SET
  subtitle = COALESCE(NULLIF(s.subtitle, ''), NULLIF(s.body::jsonb->>'subtitle', ''), ''),
  description = COALESCE(NULLIF(s.description, ''), NULLIF(s.body::jsonb->>'desc', ''), ''),
  arabic = COALESCE(s.arabic, NULLIF(s.body::jsonb->>'arabic', '')),
  arabic_en = COALESCE(s.arabic_en, NULLIF(s.body::jsonb->>'arabic_en', '')),
  icon = COALESCE(NULLIF(s.icon, ''), NULLIF(s.body::jsonb->>'icon', ''), ''),
  icon_url = COALESCE(s.icon_url, NULLIF(s.body::jsonb->>'icon_url', '')),
  repeat_label = COALESCE(s.repeat_label, NULLIF(s.body::jsonb->>'repeat', '')),
  time_label = COALESCE(s.time_label, NULLIF(s.body::jsonb->>'time', '')),
  rakaat = COALESCE(
    s.rakaat,
    CASE
      WHEN (s.body::jsonb->>'rakaat') ~ '^[0-9]+$' THEN (s.body::jsonb->>'rakaat')::integer
      ELSE NULL
    END
  ),
  accent = COALESCE(s.accent, NULLIF(s.body::jsonb->>'accent', ''))
WHERE s.guide_slug IN ('wudu', 'how-to-pray')
  AND s.body IS NOT NULL
  AND left(trim(s.body), 1) = '{'
  AND (
    jsonb_exists(s.body::jsonb, 'subtitle')
    OR jsonb_exists(s.body::jsonb, 'desc')
    OR jsonb_exists(s.body::jsonb, 'arabic')
    OR jsonb_exists(s.body::jsonb, 'time')
  );