-- Physical Quran postage is charged via PayPal (Stripe path remains for legacy rows).
-- paypal_order_id is unique so complete-paypal-order is idempotent.

ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS paypal_order_id TEXT;

ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS payment_provider TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS orders_paypal_order_id_uidx
  ON public.orders (paypal_order_id)
  WHERE paypal_order_id IS NOT NULL;

COMMENT ON COLUMN public.orders.paypal_order_id IS
  'PayPal Checkout order id for the order total (cost + postage). Set only by complete-paypal-order.';

COMMENT ON COLUMN public.orders.payment_provider IS
  'paypal or stripe. Null on older rows.';

UPDATE public.app_settings
SET
  value = jsonb_build_object(
    'product_id', 'paypal_order_total',
    'note', 'Charged totals are locked in supabase/functions/_shared/order_pricing.ts'
  ),
  description = 'Order PayPal prices are code-locked. CMS display fields do not change the amount charged.'
WHERE key = 'postage';

UPDATE public.app_settings
SET description = 'Order catalog. PayPal amounts are code-locked in order_pricing; CMS cannot change charged totals.'
WHERE key = 'order_catalog';

UPDATE public.app_settings
SET value = replace(value::text, 'Stripe', 'PayPal')::jsonb
WHERE key = 'legal_documents';
