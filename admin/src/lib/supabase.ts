import { createClient } from '@supabase/supabase-js'
import type { StaffRole } from './types'

const url = import.meta.env.VITE_SUPABASE_URL
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!url || !anonKey) {
  console.warn('Supabase env vars missing — copy admin/.env.example to admin/.env')
}

export const supabase = createClient(url ?? '', anonKey ?? '')

export async function getStaffRole(userId: string): Promise<StaffRole | null> {
  const { data, error } = await supabase.from('profiles').select('role').eq('id', userId).maybeSingle()
  if (error || !data) return null
  return data.role as StaffRole
}

export async function requireStaff() {
  const { data: { session } } = await supabase.auth.getSession()
  if (!session) return { session: null, role: null as StaffRole | null }
  const role = await getStaffRole(session.user.id)
  if (!role || role === 'user') return { session, role: null as StaffRole | null }
  return { session, role }
}

export function isAdminRole(role: StaffRole | null | undefined): boolean {
  return role === 'admin'
}
