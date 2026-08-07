-- Push broadcast history for CMS CRUD + delivery stats

CREATE TABLE IF NOT EXISTS public.push_broadcasts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  deep_link TEXT NOT NULL DEFAULT '/',
  status TEXT NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'sent', 'failed')),
  sent_count INTEGER NOT NULL DEFAULT 0,
  failed_count INTEGER NOT NULL DEFAULT 0,
  recipients INTEGER NOT NULL DEFAULT 0,
  error_message TEXT,
  created_by UUID REFERENCES auth.users (id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  sent_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS push_broadcasts_created_at_idx
  ON public.push_broadcasts (created_at DESC);

ALTER TABLE public.push_broadcasts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin read push broadcasts" ON public.push_broadcasts;
CREATE POLICY "Admin read push broadcasts"
  ON public.push_broadcasts FOR SELECT
  USING (public.is_admin());

DROP POLICY IF EXISTS "Admin write push broadcasts" ON public.push_broadcasts;
CREATE POLICY "Admin write push broadcasts"
  ON public.push_broadcasts FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

COMMENT ON TABLE public.push_broadcasts IS 'CMS push notification broadcasts (drafts + sent history).';
