-- Navigation menu items for More screen (sections, featured guide, icons)

CREATE TABLE IF NOT EXISTS public.navigation_menu_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  section TEXT NOT NULL CHECK (section IN ('featured', 'actions', 'learn', 'support', 'account')),
  label TEXT NOT NULL,
  route TEXT NOT NULL,
  icon TEXT NOT NULL DEFAULT 'chevron_right',
  subtitle TEXT,
  badge TEXT,
  published BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.navigation_menu_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read published navigation"
  ON public.navigation_menu_items FOR SELECT
  USING (published = true);

CREATE POLICY "Staff manage navigation"
  ON public.navigation_menu_items FOR ALL
  USING (public.is_staff())
  WITH CHECK (public.is_staff());

INSERT INTO public.navigation_menu_items (section, label, route, icon, subtitle, badge, sort_order) VALUES
  ('featured', 'Umrah & Hajj Guide', '/umrah-hajj', 'mosque', 'Step by step pilgrimage guide', 'Featured Guide', 0),
  ('actions', 'Donate', '/donate', 'volunteer_activism', NULL, NULL, 1),
  ('actions', 'Order Free Quran', '/order', 'local_shipping', NULL, NULL, 2),
  ('actions', 'Umrah & Hajj Guide', '/umrah-hajj', 'mosque', NULL, NULL, 3),
  ('actions', 'Ask a Scholar', '/ask-scholar', 'help_outline', NULL, NULL, 4),
  ('actions', 'Become a Distributor', '/distributor', 'storefront', NULL, NULL, 5),
  ('learn', 'New Muslim Guide', '/new-muslim', 'public', NULL, NULL, 1),
  ('learn', 'Wudu Guide', '/wudu-guide', 'water_drop', NULL, NULL, 2),
  ('learn', 'Books & Articles', '/learn', 'menu_book', NULL, NULL, 3),
  ('support', 'FAQ', '/faq', 'quiz', NULL, NULL, 1),
  ('support', 'Contact Us', '/support', 'support_agent', NULL, NULL, 2),
  ('support', 'About Us', '/about', 'info', NULL, NULL, 3),
  ('account', 'Profile & Settings', '/profile', 'settings', NULL, NULL, 1),
  ('account', 'Language', '/language', 'language', NULL, NULL, 2),
  ('account', 'Privacy Policy', '/privacy', 'privacy_tip', NULL, NULL, 3),
  ('account', 'Terms & Conditions', '/terms', 'description', NULL, NULL, 4);
