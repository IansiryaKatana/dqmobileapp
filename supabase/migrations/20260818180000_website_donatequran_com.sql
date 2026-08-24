-- Public website is donatequran.com (not .org).

UPDATE public.app_settings
SET value = replace(value::text, 'donatequran.org', 'donatequran.com')::jsonb
WHERE key IN ('external_links', 'home_campaign')
  AND value::text LIKE '%donatequran.org%';
