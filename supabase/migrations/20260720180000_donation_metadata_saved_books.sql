-- Donation metadata (donate-on-behalf, donor contact) + optional helpers

ALTER TABLE public.donations
  ADD COLUMN IF NOT EXISTS metadata JSONB NOT NULL DEFAULT '{}'::jsonb;

COMMENT ON COLUMN public.donations.metadata IS
  'Optional JSON: on_behalf_of, donor_name, donor_email, etc.';

-- Saved books (bookmark sync for Learn books)
CREATE TABLE IF NOT EXISTS public.saved_books (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  book_id TEXT NOT NULL,
  title TEXT NOT NULL,
  saved_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, book_id)
);

ALTER TABLE public.saved_books ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own saved books"
  ON public.saved_books FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
