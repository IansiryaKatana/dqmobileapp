-- Per-prayer step guides (Fajr–Isha), mirroring Wudu CMS + App Media pattern.

-- 1) Guide sections
INSERT INTO public.guide_sections (slug, title, subtitle, badge, icon, hub_group, route, published, sort_order)
VALUES
  ('pray-fajr', 'Fajr', 'How to pray Fajr · 2 rakʿah', 'Prayer', 'wb_twilight', 'learn', '/pray-guide/fajr', true, 10),
  ('pray-dhuhr', 'Dhuhr', 'How to pray Dhuhr · 4 rakʿah', 'Prayer', 'wb_sunny', 'learn', '/pray-guide/dhuhr', true, 11),
  ('pray-asr', 'Asr', 'How to pray Asr · 4 rakʿah', 'Prayer', 'wb_cloudy', 'learn', '/pray-guide/asr', true, 12),
  ('pray-maghrib', 'Maghrib', 'How to pray Maghrib · 3 rakʿah', 'Prayer', 'nights_stay', 'learn', '/pray-guide/maghrib', true, 13),
  ('pray-isha', 'Isha', 'How to pray Isha · 4 rakʿah', 'Prayer', 'dark_mode', 'learn', '/pray-guide/isha', true, 14)
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  subtitle = EXCLUDED.subtitle,
  badge = EXCLUDED.badge,
  icon = EXCLUDED.icon,
  hub_group = EXCLUDED.hub_group,
  route = EXCLUDED.route,
  published = EXCLUDED.published,
  sort_order = EXCLUDED.sort_order,
  updated_at = now();

-- 2) Shared instructional steps per prayer (rakʿah-aware copy)
-- Columns: guide_slug, title, subtitle, description, arabic, arabic_en, icon, repeat_label, sort_order
WITH prayers(slug, rakaat, name) AS (
  VALUES
    ('pray-fajr', 2, 'Fajr'),
    ('pray-dhuhr', 4, 'Dhuhr'),
    ('pray-asr', 4, 'Asr'),
    ('pray-maghrib', 3, 'Maghrib'),
    ('pray-isha', 4, 'Isha')
),
step_defs(sort_order, title, subtitle, icon, arabic, arabic_en, repeat_label, desc_tpl) AS (
  VALUES
    (1, 'Intention', 'Niyyah', 'favorite_border', NULL::text, NULL::text, NULL::text,
     'Stand facing the Qibla. Make the intention in your heart to pray {{name}} ({{rakaat}} rakʿah) for the sake of Allah.'),
    (2, 'Takbir', 'Opening takbir', 'pan_tool', 'ٱللَّهُ أَكْبَرُ', 'Allahu Akbar — Allah is the Greatest', NULL,
     'Raise both hands to the ears (or shoulders) and say Allahu Akbar to begin the prayer.'),
    (3, 'Qiyam', 'Standing · Al-Fatihah', 'menu_book', 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', 'Begin with Al-Fatihah, then a short surah', 'Each rakʿah',
     'Stand calmly with the right hand over the left. Recite Al-Fatihah, then another short surah. Do this in every rakʿah of {{name}}.'),
    (4, 'Ruku', 'Bowing', 'self_improvement', 'سُبْحَانَ رَبِّيَ ٱلْعَظِيمِ', 'Subhana Rabbiyal Azeem — Glory be to my Lord, the Most Great', '× 3',
     'Say Allahu Akbar, then bow with the back straight and hands on the knees. Glorify Allah three times.'),
    (5, 'I''tidal', 'Standing after ruku', 'accessibility_new', 'سَمِعَ ٱللَّهُ لِمَنْ حَمِدَهُ', 'Sami Allahu liman hamidah — Allah hears those who praise Him', NULL,
     'Rise from ruku, then stand upright. Say Sami Allahu liman hamidah, then Rabbana wa lakal hamd.'),
    (6, 'Sujud', 'Prostration', 'expand', 'سُبْحَانَ رَبِّيَ ٱلْأَعْلَىٰ', 'Subhana Rabbiyal A''la — Glory be to my Lord, the Most High', '× 3',
     'Say Allahu Akbar and go into prostration: forehead, nose, palms, knees, and toes on the ground. Glorify Allah three times.'),
    (7, 'Jalsa', 'Sitting between sujud', 'airline_seat_recline_normal', 'رَبِّ ٱغْفِرْ لِي', 'Rabbighfir li — My Lord, forgive me', NULL,
     'Say Allahu Akbar and sit briefly between the two prostrations. Ask Allah for forgiveness.'),
    (8, 'Second Sujud', 'Complete the rakʿah', 'expand', 'سُبْحَانَ رَبِّيَ ٱلْأَعْلَىٰ', 'Subhana Rabbiyal A''la — Glory be to my Lord, the Most High', '× 3',
     'Say Allahu Akbar and prostrate a second time. This completes one rakʿah. Stand for the next rakʿah until you finish all {{rakaat}} for {{name}}.'),
    (9, 'Tashahhud', 'Final sitting', 'volunteer_activism', 'ٱلتَّحِيَّاتُ لِلَّهِ', 'At-tahiyyatu lillah… (the tashahhud)', NULL,
     'In the last rakʿah of {{name}}, remain seated after the second sujud. Recite the tashahhud (and salawat on the Prophet ﷺ).'),
    (10, 'Salam', 'Ending the prayer', 'waving_hand', 'ٱلسَّلَامُ عَلَيْكُمْ وَرَحْمَةُ ٱللَّهِ', 'As-salamu alaykum wa rahmatullah', 'Right, then left',
     'Turn the head to the right, then to the left, saying the salam each time. Your {{name}} prayer is complete.')
)
INSERT INTO public.guide_steps (
  guide_slug, title, subtitle, description, arabic, arabic_en, icon, repeat_label, body, published, sort_order
)
SELECT
  p.slug,
  d.title,
  d.subtitle,
  replace(replace(d.desc_tpl, '{{name}}', p.name), '{{rakaat}}', p.rakaat::text),
  d.arabic,
  d.arabic_en,
  d.icon,
  d.repeat_label,
  '',
  true,
  d.sort_order
FROM prayers p
CROSS JOIN step_defs d
WHERE NOT EXISTS (
  SELECT 1 FROM public.guide_steps s WHERE s.guide_slug = p.slug
);

-- 3) App Media slots (same slot keys per prayer page)
WITH prayers(page_key) AS (
  VALUES
    ('pray-fajr'),
    ('pray-dhuhr'),
    ('pray-asr'),
    ('pray-maghrib'),
    ('pray-isha')
),
slots(slot_key, label, description, sort_order) AS (
  VALUES
    ('intention', 'Step 1 · Intention', 'Niyyah before starting', 1),
    ('takbir', 'Step 2 · Takbir', 'Opening Allahu Akbar', 2),
    ('qiyam', 'Step 3 · Qiyam', 'Standing / recitation', 3),
    ('ruku', 'Step 4 · Ruku', 'Bowing', 4),
    ('itidal', 'Step 5 · I''tidal', 'Standing after ruku', 5),
    ('sujud', 'Step 6 · Sujud', 'First prostration', 6),
    ('jalsa', 'Step 7 · Jalsa', 'Sitting between sujud', 7),
    ('sujud2', 'Step 8 · Second sujud', 'Complete the rakʿah', 8),
    ('tashahhud', 'Step 9 · Tashahhud', 'Final sitting', 9),
    ('salam', 'Step 10 · Salam', 'Ending the prayer', 10)
)
INSERT INTO public.app_page_media (page_key, slot_key, label, description, media_type, fallback_asset, sort_order)
SELECT
  p.page_key,
  s.slot_key,
  s.label,
  s.description,
  'image',
  NULL,
  s.sort_order
FROM prayers p
CROSS JOIN slots s
ON CONFLICT (page_key, slot_key) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  media_type = EXCLUDED.media_type,
  sort_order = EXCLUDED.sort_order,
  updated_at = now();
