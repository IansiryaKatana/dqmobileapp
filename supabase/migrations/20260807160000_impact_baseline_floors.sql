-- Seed historical impact floors (org ~20 years). Live computed stats use GREATEST with these.
UPDATE public.app_settings
SET
  value = '{
    "qurans_funded": 875000,
    "orders_placed": 24561,
    "countries": 32
  }'::jsonb,
  updated_at = now()
WHERE key = 'impact_overrides';
