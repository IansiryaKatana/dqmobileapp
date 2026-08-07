-- Point home banner + order product hardcoded fallbacks to new product shot.
update public.app_page_media
set
  fallback_asset = 'assets/images/donate_quran_product.png',
  updated_at = now()
where (page_key, slot_key) in (
  ('home', 'quran_banner'),
  ('order', 'product')
);
