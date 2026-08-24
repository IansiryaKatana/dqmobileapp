-- Physical Quran postage is charged via Stripe (not store IAP).
-- payment_intent_id is unique so complete-postage-order is idempotent.

ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS stripe_payment_intent_id TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS orders_stripe_payment_intent_id_uidx
  ON public.orders (stripe_payment_intent_id)
  WHERE stripe_payment_intent_id IS NOT NULL;

COMMENT ON COLUMN public.orders.stripe_payment_intent_id IS
  'Stripe PaymentIntent id for £3.99 postage. Set only by complete-postage-order.';

UPDATE public.app_settings
SET
  value = jsonb_set(
    COALESCE(value, '{}'::jsonb),
    '{product_id}',
    '"stripe_postage_399"'
  ),
  description = 'Postage display pence/label. Charged via Stripe PaymentIntent (not App Store / Play Billing).'
WHERE key = 'postage';
