-- Phase 3 CMS parity: app_settings seeds, learn guides (wudu / prayer / articles),
-- optional impact floors. Admin write policies already cover app_settings.

-- 1) Allow learn hub group on guide_sections (not shown on pilgrimage hub)
ALTER TABLE public.guide_sections
  DROP CONSTRAINT IF EXISTS guide_sections_hub_group_check;

ALTER TABLE public.guide_sections
  ADD CONSTRAINT guide_sections_hub_group_check
  CHECK (hub_group IN ('journey', 'explore', 'learn'));

-- 2) Seed app_settings keys (defaults match current Flutter hardcoded copy)
INSERT INTO public.app_settings (key, value, description) VALUES
  (
    'order_catalog',
    '{
      "hero_title": "Receive or share a free Quran copy",
      "hero_subtitle": "Quran copies are free. Postage and packaging may apply.",
      "languages": ["English", "Arabic"],
      "delivery_note": "Delivery note: Allow 5–10 business days for dispatch.",
      "products": [
        {
          "title": "1 Free Quran Copy",
          "description": "For personal use or to share",
          "route_title": "1 Free Quran Copy",
          "qty_label": "1 copy",
          "cta": "Order Free"
        },
        {
          "title": "2–9 Copies",
          "description": "Share with family and friends",
          "route_title": "2–9 Copies",
          "qty_label": "2–9 copies",
          "cta": "Order Now"
        },
        {
          "title": "Bulk Order 10+",
          "description": "For mosques and organisations",
          "route_title": "10+ Copies",
          "qty_label": "10+ copies",
          "cta": "Bulk Order"
        },
        {
          "title": "Pallet Order",
          "description": "Large-scale distribution",
          "route_title": "Pallet",
          "qty_label": "100+ copies",
          "cta": "Get in Touch"
        }
      ]
    }'::jsonb,
    'Order catalog display copy, languages, and product cards for the mobile order flow'
  ),
  (
    'postage',
    '{
      "product_id": "dq_postage_399",
      "display_pence": 399,
      "display_label": "£3.99"
    }'::jsonb,
    'Postage display pence/label. Changing store IAP price still requires App Store / RevenueCat sync for product dq_postage_399'
  ),
  (
    'about',
    '{
      "title": "About Us",
      "body": "Donate Quran is dedicated to printing and distributing English Quran copies worldwide. Through your generous donations, we fund Quran printing and help share the message of Islam."
    }'::jsonb,
    'About Us screen title and body'
  ),
  (
    'external_links',
    '{
      "privacy": "https://donatequran.org/privacy",
      "terms": "https://donatequran.org/terms",
      "distributor": "https://donatequran.org/distributor",
      "support": "https://donatequran.org/support"
    }'::jsonb,
    'External web URLs opened from More / account menu'
  ),
  (
    'impact_overrides',
    '{
      "qurans_funded": null,
      "orders_placed": null,
      "countries": null
    }'::jsonb,
    'Optional floor overrides for impact stats (GREATEST of computed vs override). Null = no override'
  ),
  (
    'donation_email_copy',
    '{
      "subject_template": "Donation receipt {{receipt_id}}",
      "intro": "Your gift of {{amount}} helps print and distribute Qurans.",
      "footer": "100% of public donations go towards Quran printing."
    }'::jsonb,
    'Donation confirmation email subject/intro/footer templates'
  ),
  (
    'push_defaults',
    '{
      "default_deep_link": "/",
      "firebase_console_hint": "Use Firebase Console → Cloud Messaging for ad-hoc broadcasts when the edge function is not configured."
    }'::jsonb,
    'Non-secret push broadcast defaults for admin UI'
  )
ON CONFLICT (key) DO NOTHING;

-- 3) Learn guide sections (managed in Admin → Guides; hub_group=learn)
INSERT INTO public.guide_sections (slug, title, subtitle, badge, icon, hub_group, route, sort_order) VALUES
  ('wudu', 'Wudu Guide', 'How to make ablution', 'Step by Step', 'water_drop', 'learn', '/wudu-guide', 1),
  ('how-to-pray', 'How to Pray', 'Step-by-step salah guide', 'Practice', 'self_improvement', 'learn', '/how-to-pray', 2),
  ('what-is-islam', 'What is Islam?', 'The fundamentals of the faith', 'Faith', 'mosque', 'learn', '/what-is-islam', 3),
  ('what-is-quran', 'What is the Quran?', 'The holy book of Islam', 'Revelation', 'menu_book', 'learn', '/what-is-quran', 4),
  ('who-is-prophet', 'Prophet Muhammad ﷺ', 'His life and teachings', 'Prophethood', 'person', 'learn', '/who-is-prophet', 5)
ON CONFLICT (slug) DO NOTHING;

-- 4) Wudu steps (body JSON for rich fields; title = step name)
INSERT INTO public.guide_steps (guide_slug, title, body, sort_order)
SELECT v.guide_slug, v.title, v.body, v.sort_order
FROM (VALUES
  ('wudu', 'Bismillah', '{"subtitle":"Intention","desc":"Before Wudu: Make the intention in your heart. Then say:","arabic":"بِسۡمِ اللهِ","arabic_en":"Bismillah — In the name of Allah","icon":"favorite_border"}', 1),
  ('wudu', 'Hands', '{"subtitle":"Wash both hands","repeat":"× 3 times","desc":"Completely wash both hands, including the wrists and between the fingers.","icon":"back_hand"}', 2),
  ('wudu', 'Mouth', '{"subtitle":"Rinse the mouth","repeat":"× 3 times","desc":"Using the right hand, put a small amount of water into the mouth, swirl it around, then expel.","icon":"water_drop"}', 3),
  ('wudu', 'Nose', '{"subtitle":"Rinse the nostrils","repeat":"× 3 times","desc":"Sniff water into the nostrils as far as possible with the right hand, then blow it out using the left hand.","icon":"air"}', 4),
  ('wudu', 'Face', '{"subtitle":"Wash the full face","repeat":"× 3 times","desc":"Wash the face from the hairline to the chin, and from earlobe to earlobe — the entire face must be covered.","icon":"face"}', 5),
  ('wudu', 'Arms', '{"subtitle":"Wash to the elbows","repeat":"× 3 times","desc":"Wash both arms to and including the elbows, including between the fingers. Begin with the right arm.","icon":"pan_tool"}', 6),
  ('wudu', 'Head', '{"subtitle":"Wipe the head","desc":"Wipe the head with wet fingers, starting at the fringe to the back hairline and back again — all in one movement.","icon":"self_improvement"}', 7),
  ('wudu', 'Ears', '{"subtitle":"Wipe both ears","desc":"Simultaneously wipe the insides of both ears with the index fingers and the back of the ears with the thumbs.","icon":"hearing"}', 8),
  ('wudu', 'Feet', '{"subtitle":"Wash to the ankles","repeat":"× 3 times","desc":"Wash both feet including the ankles and between the toes. Begin with the right foot.","icon":"directions_walk"}', 9),
  ('wudu', 'Closing Du''a', '{"subtitle":"Invocation","desc":"After Wudu, say:","arabic":"أَشْهَدُ أَن لَّا إِلَٰهَ إِلَّا ٱللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ","arabic_en":"Ash-hadu an lā ilāha illallāh, wa ash-hadu anna Muḥammadan ʿabduhu wa rasūluh. (I bear witness that there is no god but Allah, and Muhammad is His servant and messenger.)","icon":"check_circle"}', 10)
) AS v(guide_slug, title, body, sort_order)
WHERE EXISTS (SELECT 1 FROM public.guide_sections g WHERE g.slug = 'wudu')
  AND NOT EXISTS (SELECT 1 FROM public.guide_steps s WHERE s.guide_slug = 'wudu');

-- 5) How to pray — five daily prayers
INSERT INTO public.guide_steps (guide_slug, title, body, sort_order)
SELECT v.guide_slug, v.title, v.body, v.sort_order
FROM (VALUES
  ('how-to-pray', 'Fajr', '{"arabic":"الفجر","time":"Before sunrise","rakaat":2,"accent":"#FF8C42"}', 1),
  ('how-to-pray', 'Dhuhr', '{"arabic":"الظهر","time":"Midday","rakaat":4,"accent":"#10B981"}', 2),
  ('how-to-pray', 'Asr', '{"arabic":"العصر","time":"Afternoon","rakaat":4,"accent":"#6366F1"}', 3),
  ('how-to-pray', 'Maghrib', '{"arabic":"المغرب","time":"After sunset","rakaat":3,"accent":"#F43F5E"}', 4),
  ('how-to-pray', 'Isha', '{"arabic":"العشاء","time":"Night","rakaat":4,"accent":"#0B1F3A"}', 5)
) AS v(guide_slug, title, body, sort_order)
WHERE EXISTS (SELECT 1 FROM public.guide_sections g WHERE g.slug = 'how-to-pray')
  AND NOT EXISTS (SELECT 1 FROM public.guide_steps s WHERE s.guide_slug = 'how-to-pray');

-- 6) What is Islam / Quran / Prophet article sections
INSERT INTO public.guide_steps (guide_slug, title, body, sort_order)
SELECT v.guide_slug, v.title, v.body, v.sort_order
FROM (VALUES
  ('what-is-islam', 'The Meaning of Islam', 'Islam is an Arabic word meaning "submission" or "peace through submission to the will of God." It is not a new religion — Islam is the same message of pure monotheism that was revealed to all prophets, from Adam, to Abraham, to Moses, to Jesus, and finally to Muhammad ﷺ.', 1),
  ('what-is-islam', 'The Six Articles of Faith', 'Muslims believe in: (1) Allah — the One God, unique and without partners; (2) The Angels — created from light, they worship Allah continuously; (3) The Books — including the Torah, Psalms, Gospel, and the Quran; (4) The Prophets — over 124,000 prophets were sent to guide mankind; (5) The Day of Judgement — all souls will be accountable; (6) Divine Decree — Allah''s complete knowledge of all things.', 2),
  ('what-is-islam', 'The Five Pillars', 'The Five Pillars are the core practices of Islam: (1) Shahada — declaration of faith; (2) Salah — five daily prayers; (3) Zakat — giving 2.5% of wealth in charity; (4) Sawm — fasting during Ramadan; (5) Hajj — pilgrimage to Makkah at least once in a lifetime for those able.', 3),
  ('what-is-islam', 'Why People Embrace Islam', 'People come to Islam from every background and culture. What draws them is often the clarity of monotheism, the directness of the connection to God without intermediaries, and the comprehensive way Islam guides all aspects of life — from personal worship to ethics, family, and society.', 4),
  ('what-is-quran', 'The Word of Allah', 'The Quran is the final revelation from Allah (God), revealed to the Prophet Muhammad ﷺ over 23 years through the Angel Jibreel (Gabriel). It is the primary source of Islamic law and guidance, and the central text of Muslim life.', 1),
  ('what-is-quran', 'Its Structure', 'The Quran consists of 114 chapters (surahs), ranging from long detailed chapters to short powerful ones. It contains 6,236 verses (ayat). The chapters are arranged generally from longest to shortest, not in the order of revelation.', 2),
  ('what-is-quran', 'Its Miraculous Nature', 'Muslims believe the Quran is a miracle — its literary style, precision, and depth are considered humanly impossible to replicate. It has been memorised in its entirety by millions (known as Hafiz) and preserved unchanged for over 1,400 years in the original Arabic.', 3),
  ('what-is-quran', 'The Quran in Daily Life', 'The Quran is recited in every prayer, studied for guidance, recited at births and deaths, and memorised as an act of worship. It covers theology, law, stories of past prophets, moral guidance, and direct address to the human soul.', 4),
  ('who-is-prophet', 'His Early Life', 'Muhammad ﷺ was born in Makkah in 570 CE into the noble tribe of Quraysh. He was orphaned young — his father died before his birth and his mother passed when he was six. He grew up known as ''Al-Amin'' (The Trustworthy) for his outstanding character, honesty, and reliability.', 1),
  ('who-is-prophet', 'The Prophethood', 'At the age of 40, while meditating in the Cave of Hira near Makkah, the Angel Jibreel appeared and delivered the first revelation of the Quran: ''Read in the name of your Lord who created.'' (96:1). This marked the beginning of his mission to call humanity to pure monotheism.', 2),
  ('who-is-prophet', 'His Character', 'The Prophet ﷺ was described as the walking Quran — his entire life embodied its teachings. He was known for extraordinary mercy, patience, and humility. He said: "The best of you are those who have the best manners and character." His sunnah (way of life) forms the second source of Islamic guidance after the Quran.', 3),
  ('who-is-prophet', 'His Legacy', 'In just 23 years, the message of Islam spread across Arabia. Within a century of his passing, it had reached from Spain to China. Today, over 1.9 billion people follow his teachings. He is considered the final prophet — the seal of all prophets — bringing the complete and preserved message of monotheism to all of humanity.', 4)
) AS v(guide_slug, title, body, sort_order)
WHERE EXISTS (SELECT 1 FROM public.guide_sections g WHERE g.slug = v.guide_slug)
  AND NOT EXISTS (SELECT 1 FROM public.guide_steps s WHERE s.guide_slug = v.guide_slug);
