-- Pilgrimage guide sections and steps (Umrah, Hajj, explore topics)

CREATE TABLE IF NOT EXISTS public.guide_sections (
  slug TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL DEFAULT '',
  badge TEXT NOT NULL DEFAULT '',
  icon TEXT NOT NULL DEFAULT 'mosque',
  hub_group TEXT NOT NULL DEFAULT 'journey' CHECK (hub_group IN ('journey', 'explore')),
  route TEXT NOT NULL DEFAULT '',
  published BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.guide_steps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  guide_slug TEXT NOT NULL REFERENCES public.guide_sections(slug) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  published BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS guide_steps_slug_order_idx ON public.guide_steps(guide_slug, sort_order);

ALTER TABLE public.guide_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guide_steps ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read published guide sections"
  ON public.guide_sections FOR SELECT
  USING (published = true);

CREATE POLICY "Staff manage guide sections"
  ON public.guide_sections FOR ALL
  USING (public.is_staff())
  WITH CHECK (public.is_staff());

CREATE POLICY "Public read published guide steps"
  ON public.guide_steps FOR SELECT
  USING (
    published = true
    AND EXISTS (
      SELECT 1 FROM public.guide_sections g
      WHERE g.slug = guide_steps.guide_slug AND g.published = true
    )
  );

CREATE POLICY "Staff manage guide steps"
  ON public.guide_steps FOR ALL
  USING (public.is_staff())
  WITH CHECK (public.is_staff());

-- Hub screen copy
INSERT INTO public.app_settings (key, value, description) VALUES
  (
    'pilgrimage_hub',
    '{
      "eyebrow": "Seeking the Pleasure of Allah",
      "title": "UMRAH & HAJJ GUIDE",
      "disclaimer": "All guides are based on authentic scholarly sources. Always consult a qualified scholar for personal rulings."
    }',
    'Umrah & Hajj hub hero and disclaimer copy'
  )
ON CONFLICT (key) DO NOTHING;

-- Hub cards / explore tiles
INSERT INTO public.guide_sections (slug, title, subtitle, badge, icon, hub_group, route, sort_order) VALUES
  ('umrah', 'Umrah Guide', 'Rituals, du''as & essential tips', 'Step by Step', 'mosque', 'journey', '/guide/umrah', 1),
  ('hajj', 'Hajj Guide', 'Pillars, locations & rituals', 'Step by Step', 'landscape', 'journey', '/guide/hajj', 2),
  ('spiritual-preparation', 'Spiritual Preparation', 'Prepare your heart before travel', '', 'volunteer_activism', 'explore', '/guide/spiritual-preparation', 1),
  ('visiting-madinah', 'Visiting Madinah', 'Adab and visits in the blessed city', '', 'location_city', 'explore', '/guide/visiting-madinah', 2),
  ('logistics', 'Logistics', 'Travel, documents & packing', '', 'luggage', 'explore', '/guide/logistics', 3),
  ('faq', 'FAQ', 'Common pilgrimage questions', '', 'quiz', 'explore', '/faq', 4)
ON CONFLICT (slug) DO NOTHING;

-- Umrah steps
INSERT INTO public.guide_steps (guide_slug, title, body, sort_order) VALUES
  ('umrah', 'Enter Ihram at the Miqat', 'Make intention for Umrah and wear the Ihram garments before crossing the designated boundary.', 1),
  ('umrah', 'Recite the Talbiyah', '“Labbayk Allahumma labbayk…” — continue until you begin Tawaf at the Kaaba.', 2),
  ('umrah', 'Perform Tawaf', 'Circle the Kaaba seven times, starting and ending at the Black Stone, with humility and dhikr.', 3),
  ('umrah', 'Pray two rak''ahs at Maqam Ibrahim', 'If crowded, pray anywhere in the Haram.', 4),
  ('umrah', 'Drink Zamzam', 'Make du''a while drinking — the Prophet ﷺ said Zamzam is for whatever it is drunk for.', 5),
  ('umrah', 'Perform Sa''i', 'Walk seven times between Safa and Marwah, starting at Safa and ending at Marwah.', 6),
  ('umrah', 'Shave or trim hair (Halq/Taqsir)', 'Men shave or shorten hair; women trim a fingertip-length from the ends.', 7),
  ('umrah', 'Umrah is complete', 'You exit the state of Ihram. May Allah accept your worship.', 8);

-- Hajj steps
INSERT INTO public.guide_steps (guide_slug, title, body, sort_order) VALUES
  ('hajj', 'Enter Ihram for Hajj', 'Assume Ihram at the Miqat with intention for Hajj on the prescribed days.', 1),
  ('hajj', 'Tawaf al-Qudum (arrival Tawaf)', 'Upon reaching Makkah, perform the welcome Tawaf if time allows before the days of Hajj.', 2),
  ('hajj', 'Day of Arafah (Wuquf)', 'Stand at Arafat from midday until sunset — the greatest pillar of Hajj.', 3),
  ('hajj', 'Muzdalifah', 'After sunset on Arafah, proceed to Muzdalifah and combine Maghrib and Isha.', 4),
  ('hajj', 'Rami al-Jamarat', 'Stone the pillars at Mina on the days of Tashreeq, following the Sunnah.', 5),
  ('hajj', 'Sacrifice (Hady)', 'Offer the sacrifice if required — often arranged through your group or agent.', 6),
  ('hajj', 'Shave or trim hair', 'Men shave or shorten; women trim. Partial release from Ihram restrictions follows.', 7),
  ('hajj', 'Tawaf al-Ifadah', 'An essential pillar — perform Tawaf and Sa''i after the day of Eid.', 8),
  ('hajj', 'Farewell Tawaf (Tawaf al-Wada'')', 'Before leaving Makkah, perform a final Tawaf as the farewell to the Haram.', 9);

-- Spiritual preparation
INSERT INTO public.guide_steps (guide_slug, title, body, sort_order) VALUES
  ('spiritual-preparation', 'Renew your intention', 'Purify your niyyah: seek Allah''s pleasure alone, not praise or social media. Write your personal du''a list before departure.', 1),
  ('spiritual-preparation', 'Learn essential du''as', 'Memorise or save Talbiyah, entering the Haram, Tawaf, Sa''i, and Arafah du''as. Keep a small printed or offline copy.', 2),
  ('spiritual-preparation', 'Seek forgiveness', 'Repent sincerely and settle debts or grudges where possible. Ask loved ones for pardon before travelling.', 3),
  ('spiritual-preparation', 'Increase worship at home', 'Pray on time, read Quran daily, and give charity in the weeks before travel so your heart is already inclined to worship.', 4),
  ('spiritual-preparation', 'Study the rituals', 'Understand the order of Umrah or Hajj rites from a trusted teacher or app guide so you are not learning only on the ground.', 5),
  ('spiritual-preparation', 'Prepare patience', 'Crowds, heat, and delays are part of the journey. Expect hardship and intend sabr for the sake of Allah.', 6);

-- Visiting Madinah
INSERT INTO public.guide_steps (guide_slug, title, body, sort_order) VALUES
  ('visiting-madinah', 'Enter with adab', 'Approach Madinah with humility, abundant salawat upon the Prophet ﷺ, and awareness that you are a guest in the illuminated city.', 1),
  ('visiting-madinah', 'Pray in Masjid an-Nabawi', 'Give priority to obligatory prayers in congregation. The reward for prayer in this mosque is multiplied — plan your schedule around salah.', 2),
  ('visiting-madinah', 'Visit the Rawdah if possible', 'The area between the Prophet''s ﷺ pulpit and grave is from the gardens of Paradise. Book permitted visiting slots when required and maintain calm.', 3),
  ('visiting-madinah', 'Send salawat at the Prophet''s ﷺ grave', 'Stand facing the grave with adab, not raising the voice. Greet the Prophet ﷺ, Abu Bakr and Umar (may Allah be pleased with them) with the prescribed phrases.', 4),
  ('visiting-madinah', 'Pray at Masjid Quba', 'If you can, pray two rak''ahs in Masjid Quba — the first mosque built in Islam — following the Sunnah of the Prophet ﷺ.', 5),
  ('visiting-madinah', 'Visit Uhud with reflection', 'Remember the martyrs of Uhud, especially Hamzah (may Allah be pleased with him). Make du''a and take lessons in loyalty and sacrifice.', 6);

-- Logistics
INSERT INTO public.guide_steps (guide_slug, title, body, sort_order) VALUES
  ('logistics', 'Documents and visa', 'Ensure passport validity (often six months beyond travel), approved visa, vaccination records if required, and printed copies of bookings.', 1),
  ('logistics', 'Flights and transfers', 'Confirm arrival city (Jeddah or Madinah), baggage allowance for ihram and gifts, and group pickup arrangements.', 2),
  ('logistics', 'Accommodation', 'Save hotel addresses in Arabic and English, note proximity to Haram gates, and share location with family at home.', 3),
  ('logistics', 'Ihram and clothing', 'Pack two sets of ihram if possible, safety pins, sandals that expose ankles, and a waist pouch for essentials.', 4),
  ('logistics', 'Health and comfort', 'Carry prescribed medicines, rehydration salts, unscented soap for ihram, and a light foldable mat or prayer garment.', 5),
  ('logistics', 'Money and connectivity', 'Use a mix of cards and cash (Saudi riyal). Download offline maps, Quran, and du''a apps before departure.', 6);
