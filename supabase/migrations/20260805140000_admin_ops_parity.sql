-- Admin ops parity: scholar answers, is_admin(), staff order/scholar updates,
-- admin-only profiles + app_settings writes.

-- 1) Scholar answers (in-app)
ALTER TABLE public.scholar_questions
  ADD COLUMN IF NOT EXISTS answer TEXT,
  ADD COLUMN IF NOT EXISTS answered_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS answered_by UUID REFERENCES auth.users(id) ON DELETE SET NULL;

COMMENT ON COLUMN public.scholar_questions.answer IS 'Staff-written answer shown in the mobile My Questions screen';
COMMENT ON COLUMN public.scholar_questions.answered_at IS 'When answer was last saved (non-empty)';
COMMENT ON COLUMN public.scholar_questions.answered_by IS 'auth.users id of staff who saved the answer';

-- 2) Document allowed order statuses (do not enforce CHECK — avoid breaking existing rows)
COMMENT ON COLUMN public.orders.status IS
  'Allowed: pending, paid, processing, shipped, delivered, cancelled';

-- 3) is_admin() — mirrors is_staff() but admin role only
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 4) Staff UPDATE orders
DROP POLICY IF EXISTS "Staff update orders" ON public.orders;
CREATE POLICY "Staff update orders"
  ON public.orders FOR UPDATE
  USING (public.is_staff())
  WITH CHECK (public.is_staff());

-- 5) Staff UPDATE scholar_questions
DROP POLICY IF EXISTS "Staff update scholar questions" ON public.scholar_questions;
CREATE POLICY "Staff update scholar questions"
  ON public.scholar_questions FOR UPDATE
  USING (public.is_staff())
  WITH CHECK (public.is_staff());

-- 6) Admin SELECT all profiles
DROP POLICY IF EXISTS "Admin view all profiles" ON public.profiles;
CREATE POLICY "Admin view all profiles"
  ON public.profiles FOR SELECT
  USING (public.is_admin());

-- 7) Admin UPDATE profiles (role / name)
DROP POLICY IF EXISTS "Admin update profiles" ON public.profiles;
CREATE POLICY "Admin update profiles"
  ON public.profiles FOR UPDATE
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- 8) Tighten app_settings writes to admin only (keep public SELECT)
DROP POLICY IF EXISTS "Staff manage app settings" ON public.app_settings;
DROP POLICY IF EXISTS "Admin manage app settings" ON public.app_settings;
CREATE POLICY "Admin manage app settings"
  ON public.app_settings FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());
