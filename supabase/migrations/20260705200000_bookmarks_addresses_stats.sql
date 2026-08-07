-- Bookmarks, saved content, addresses, and public impact stats

CREATE TABLE IF NOT EXISTS public.quran_bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  surah_number INTEGER NOT NULL,
  surah_name TEXT NOT NULL,
  ayah_number INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, surah_number, ayah_number)
);

ALTER TABLE public.quran_bookmarks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own quran bookmarks"
  ON public.quran_bookmarks FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.saved_articles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  article_id TEXT NOT NULL,
  title TEXT NOT NULL,
  saved_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, article_id)
);

ALTER TABLE public.saved_articles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own saved articles"
  ON public.saved_articles FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.saved_addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  label TEXT NOT NULL DEFAULT 'Home',
  line1 TEXT NOT NULL,
  city TEXT NOT NULL,
  postcode TEXT NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.saved_addresses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own addresses"
  ON public.saved_addresses FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE OR REPLACE VIEW public.impact_stats AS
SELECT
  GREATEST(
    (SELECT COALESCE(SUM(amount_pence), 0) / 500 FROM public.donations WHERE status IN ('completed', 'subscription_active')),
    0
  )::INTEGER AS qurans_funded,
  (SELECT COUNT(*)::INTEGER FROM public.orders) AS orders_placed,
  GREATEST(
    (SELECT COUNT(DISTINCT (address->>'city'))::INTEGER FROM public.orders WHERE address IS NOT NULL),
    1
  ) AS countries;

GRANT SELECT ON public.impact_stats TO anon, authenticated;
