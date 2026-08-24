-- CMS tables for TanStack admin + mobile app content

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'user'
  CHECK (role IN ('user', 'editor', 'admin'));

-- Published content (articles, books, campaigns)
CREATE TABLE IF NOT EXISTS public.content_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  summary TEXT NOT NULL DEFAULT '',
  body TEXT NOT NULL DEFAULT '',
  topic TEXT NOT NULL DEFAULT 'General',
  kind TEXT NOT NULL DEFAULT 'article' CHECK (kind IN ('article', 'book', 'campaign')),
  image_url TEXT,
  published BOOLEAN NOT NULL DEFAULT false,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.faq_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  published BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.quran_topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  surah_numbers INTEGER[] NOT NULL DEFAULT '{}',
  published BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Non-secret app configuration (RevenueCat offering IDs, copy, feature flags)
CREATE TABLE IF NOT EXISTS public.app_settings (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL DEFAULT '{}',
  description TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.content_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.faq_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quran_topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.is_staff()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role IN ('editor', 'admin')
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Public read published content
CREATE POLICY "Public read published content"
  ON public.content_items FOR SELECT
  USING (published = true);

CREATE POLICY "Staff manage content"
  ON public.content_items FOR ALL
  USING (public.is_staff())
  WITH CHECK (public.is_staff());

CREATE POLICY "Public read published faq"
  ON public.faq_items FOR SELECT
  USING (published = true);

CREATE POLICY "Staff manage faq"
  ON public.faq_items FOR ALL
  USING (public.is_staff())
  WITH CHECK (public.is_staff());

CREATE POLICY "Public read published topics"
  ON public.quran_topics FOR SELECT
  USING (published = true);

CREATE POLICY "Staff manage topics"
  ON public.quran_topics FOR ALL
  USING (public.is_staff())
  WITH CHECK (public.is_staff());

-- App settings: public read non-sensitive keys; staff write
CREATE POLICY "Public read app settings"
  ON public.app_settings FOR SELECT
  USING (true);

CREATE POLICY "Staff manage app settings"
  ON public.app_settings FOR ALL
  USING (public.is_staff())
  WITH CHECK (public.is_staff());

-- Staff ops read access for admin dashboard
CREATE POLICY "Staff view all donations"
  ON public.donations FOR SELECT
  USING (public.is_staff());

CREATE POLICY "Staff view all orders"
  ON public.orders FOR SELECT
  USING (public.is_staff());

CREATE POLICY "Staff view all scholar questions"
  ON public.scholar_questions FOR SELECT
  USING (public.is_staff());

-- Storage bucket for CMS media (create in dashboard if migration cannot)
INSERT INTO storage.buckets (id, name, public)
VALUES ('cms-media', 'cms-media', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Public read cms media"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'cms-media');

CREATE POLICY "Staff upload cms media"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'cms-media' AND public.is_staff());

CREATE POLICY "Staff update cms media"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'cms-media' AND public.is_staff());

CREATE POLICY "Staff delete cms media"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'cms-media' AND public.is_staff());

-- Seed content from app defaults
INSERT INTO public.content_items (slug, title, summary, body, topic, kind, published, sort_order) VALUES
  ('fatihah', 'Understanding Surah Al-Fatihah', 'The opening chapter and its significance.', 'Surah Al-Fatihah is the opening chapter of the Quran and is recited in every unit of Muslim prayer.', 'Quran', 'article', true, 1),
  ('pillars', 'The Five Pillars of Islam', 'Foundation of Muslim practice.', 'The five pillars are the framework of Muslim life: Shahada, Salah, Zakat, Sawm, and Hajj.', 'Faith', 'article', true, 2),
  ('wudu-intro', 'Introduction to Wudu', 'Purification before prayer.', 'Wudu is the ritual washing performed before prayer.', 'Prayer', 'article', true, 3),
  ('new-muslim-prayer', 'Learning to Pray as a New Muslim', 'A gentle starting guide.', 'Learning to pray takes time and patience. Start with one prayer and build consistency.', 'New Muslim', 'article', true, 4),
  ('book-new-muslim', 'New Muslim Guide', 'Essential first steps in Islam.', 'A curated path covering belief, prayer, Quran, and community.', 'Books', 'book', true, 1),
  ('book-wudu', 'Wudu & Purification', 'Complete purification guide.', 'Step-by-step wudu with common questions answered for new Muslims.', 'Books', 'book', true, 2)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.faq_items (question, answer, sort_order) VALUES
  ('Where does my donation go?', '100% of public donations go towards Quran printing and distribution.', 1),
  ('Is the Quran really free?', 'Yes, Quran copies are free. Postage and packaging may apply for orders.', 2),
  ('How long does delivery take?', 'Typically 5–10 business days depending on your location.', 3);

INSERT INTO public.quran_topics (name, description, surah_numbers, sort_order) VALUES
  ('Mercy & Compassion', 'Surahs highlighting Allah''s mercy', ARRAY[1, 55, 93], 1),
  ('Patience & Trials', 'Strength through difficulty', ARRAY[2, 12, 94], 2),
  ('Prayer & Worship', 'Guidance on salah and devotion', ARRAY[1, 87, 103], 3),
  ('Stories of Prophets', 'Lessons from earlier nations', ARRAY[12, 19, 21], 4);

INSERT INTO public.app_settings (key, value, description) VALUES
  ('revenuecat', '{"offering_id":"default","monthly_package_id":"monthly","note":"API keys are set in mobile CI env only — not stored here."}', 'RevenueCat offering configuration (no secrets)'),
  ('home_campaign', '{"title":"Support Quran Printing","subtitle":"View our impact report","link":"https://donatequran.com/impact"}', 'Home screen campaign card'),
  ('donate_copy', '{"tagline":"100% of public donations go towards Quran printing.","guest_message":"No account needed — donate as a guest."}', 'Donate screen copy')
ON CONFLICT (key) DO NOTHING;
