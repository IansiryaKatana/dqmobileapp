-- Quran order Cost + Postage totals (Stripe). cost_pence is the contribution;
-- postage_pence is P&P. Total charged = cost_pence + postage_pence.

ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS cost_pence INTEGER NOT NULL DEFAULT 0;

COMMENT ON COLUMN public.orders.cost_pence IS
  'Quran contribution in pence (GBP). 0 for the free single copy.';

COMMENT ON COLUMN public.orders.postage_pence IS
  'Postage and packaging in pence (GBP). Charged with cost_pence via Stripe.';

COMMENT ON COLUMN public.orders.stripe_payment_intent_id IS
  'Stripe PaymentIntent id for the order total (cost + postage). Set only by complete-postage-order.';

UPDATE public.app_settings
SET
  value = '{
    "hero_title": "Order a Quran copy",
    "hero_subtitle": "The first Quran is free. Extra copies include a contribution plus postage.",
    "languages": ["English", "Arabic"],
    "delivery_note": "Allow 5–10 business days for dispatch.",
    "products": [
      {
        "title": "1 Quran",
        "description": "Free copy. You pay postage and packaging.",
        "route_title": "1 Quran",
        "qty_label": "1 copy · £7.50 total",
        "cta": "Order Free",
        "pack_kind": "copies",
        "min_qty": 1,
        "max_qty": 1
      },
      {
        "title": "2–9 Qurans",
        "description": "Share with family and friends",
        "route_title": "2–9 Qurans",
        "qty_label": "2–9 copies",
        "cta": "Order Now",
        "pack_kind": "copies",
        "min_qty": 2,
        "max_qty": 9
      },
      {
        "title": "Boxes",
        "description": "10 Qurans per box, for mosques and organisations",
        "route_title": "Boxes",
        "qty_label": "1–15 boxes",
        "cta": "Order Boxes",
        "pack_kind": "boxes",
        "min_qty": 1,
        "max_qty": 15
      }
    ]
  }'::jsonb,
  description = 'Order catalog. Stripe amounts are code-locked in order_pricing; CMS cannot change charged totals.'
WHERE key = 'order_catalog';

UPDATE public.app_settings
SET
  value = jsonb_build_object(
    'product_id', 'stripe_order_total',
    'note', 'Charged totals are locked in supabase/functions/_shared/order_pricing.ts'
  ),
  description = 'Order Stripe prices are code-locked. CMS display fields do not change the amount charged.'
WHERE key = 'postage';
