-- App page media: CMS-overridable icons/images with seeded fallback asset paths.

CREATE TABLE IF NOT EXISTS public.app_page_media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  page_key TEXT NOT NULL,
  slot_key TEXT NOT NULL,
  label TEXT NOT NULL DEFAULT '',
  description TEXT NOT NULL DEFAULT '',
  media_type TEXT NOT NULL DEFAULT 'image' CHECK (media_type IN ('image', 'icon')),
  url TEXT,
  fallback_asset TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (page_key, slot_key)
);

CREATE INDEX IF NOT EXISTS app_page_media_page_idx ON public.app_page_media (page_key, sort_order);

ALTER TABLE public.app_page_media ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read page media" ON public.app_page_media;
CREATE POLICY "Public read page media"
  ON public.app_page_media FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Staff manage page media" ON public.app_page_media;
CREATE POLICY "Staff manage page media"
  ON public.app_page_media FOR ALL
  USING (public.is_staff())
  WITH CHECK (public.is_staff());

COMMENT ON TABLE public.app_page_media IS 'Per-screen media slots; url overrides bundled fallback_asset in the Flutter app.';

INSERT INTO public.app_page_media (page_key, slot_key, label, description, media_type, fallback_asset, sort_order) VALUES
  ('onboarding', 'logo', 'Onboarding logo', 'Wordmark on welcome / onboarding', 'image', 'assets/images/donate_quran_logo.png', 1),
  ('home', 'quran_banner', 'Home Quran banner', 'Read Quran hero image on Home', 'image', 'assets/images/donate_quran_product.png', 1),
  ('home', 'app_icon', 'App icon preview', 'Brand mark used in headers', 'image', 'assets/images/app_icon.png', 2),
  ('order', 'product', 'Order product shot', 'Quran product image on Order flow', 'image', 'assets/images/donate_quran_product.png', 1),
  ('qibla', 'compass_mark', 'Qibla compass mark', 'Optional custom Kaaba / compass center mark', 'icon', 'assets/icons/kaaba.svg', 1),
  ('more', 'kaaba_icon', 'More · Kaaba icon', 'Kaaba icon on More / pilgrimage entry', 'icon', 'assets/icons/kaaba.svg', 1),
  ('pilgrimage', 'featured_kaaba', 'Pilgrimage featured Kaaba', 'Large Kaaba on Umrah & Hajj hub', 'icon', 'assets/icons/kaaba.svg', 1),
  ('logistics', 'visa', 'Logistics · Visa', 'Visa tip card image', 'image', 'assets/images/logistics_visa.jpg', 1),
  ('logistics', 'ihram', 'Logistics · Ihram', 'Ihram tip card image', 'image', 'assets/images/logistics_ihram.jpg', 2),
  ('logistics', 'haram', 'Logistics · Haram', 'Masjid al-Haram tip card', 'image', 'assets/images/logistics_haram.jpg', 3),
  ('logistics', 'nabawi', 'Logistics · Nabawi', 'Masjid an-Nabawi tip card', 'image', 'assets/images/logistics_nabawi.jpg', 4),
  ('logistics', 'jannat', 'Logistics · Jannat', 'Jannat al-Baqi tip card', 'image', 'assets/images/logistics_jannat.jpg', 5),
  ('logistics', 'nusuk', 'Logistics · Nusuk', 'Nusuk app tip card', 'image', 'assets/images/logistics_nusuk.jpg', 6),
  ('guides', 'wudu_hero', 'Wudu step illustration', 'Default illustration area for Wudu steps (per-step icons also in Guides)', 'image', NULL, 1),
  ('donate', 'hero', 'Donate hero', 'Optional donate screen hero image', 'image', NULL, 1)
ON CONFLICT (page_key, slot_key) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  media_type = EXCLUDED.media_type,
  fallback_asset = COALESCE(public.app_page_media.fallback_asset, EXCLUDED.fallback_asset),
  sort_order = EXCLUDED.sort_order,
  updated_at = now();
