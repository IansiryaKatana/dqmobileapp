-- Allow guest donations and orders when user_id is null
DROP POLICY IF EXISTS "Users can insert own donations" ON public.donations;
CREATE POLICY "Users can insert donations"
  ON public.donations FOR INSERT
  WITH CHECK (user_id IS NULL OR auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own orders" ON public.orders;
CREATE POLICY "Users can insert orders"
  ON public.orders FOR INSERT
  WITH CHECK (user_id IS NULL OR auth.uid() = user_id);
