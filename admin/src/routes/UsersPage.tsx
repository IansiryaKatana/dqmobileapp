import { useMemo, useState } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { useRouteContext } from '@tanstack/react-router'
import type { ColumnDef } from '@tanstack/react-table'
import { toast } from 'sonner'
import { DataTable } from '@/components/DataTable'
import { PageHeader } from '@/components/PageHeader'
import { Badge } from '@/components/ui/badge'
import { Label } from '@/components/ui/label'
import { Input } from '@/components/ui/input'
import { supabase } from '@/lib/supabase'
import type { ProfileRow, StaffRole } from '@/lib/types'

const ROLES: StaffRole[] = ['user', 'editor', 'admin']

export function UsersPage() {
  const queryClient = useQueryClient()
  const { session } = useRouteContext({ from: '/_admin' })
  const [searchTerm, setSearchTerm] = useState('')
  const [updatingId, setUpdatingId] = useState<string | null>(null)

  const { data = [], isLoading } = useQuery({
    queryKey: ['profiles-admin'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('profiles')
        .select('id, email, name, role, created_at')
        .order('created_at', { ascending: false })
      if (error) throw error
      return data as ProfileRow[]
    },
  })

  const adminCount = data.filter((p) => p.role === 'admin').length
  const filtered = useMemo(() => {
    const term = searchTerm.trim().toLowerCase()
    if (!term) return data
    return data.filter(
      (p) =>
        p.email.toLowerCase().includes(term) ||
        p.name.toLowerCase().includes(term) ||
        p.role.toLowerCase().includes(term)
    )
  }, [data, searchTerm])

  async function updateRole(profile: ProfileRow, role: StaffRole) {
    if (role === profile.role) return

    if (
      profile.id === session.user.id &&
      profile.role === 'admin' &&
      role !== 'admin' &&
      adminCount <= 1
    ) {
      toast.error('You are the only admin — promote someone else before demoting yourself')
      return
    }

    if (profile.id === session.user.id && profile.role === 'admin' && role !== 'admin') {
      const ok = window.confirm(
        'You are demoting your own admin role. You may lose access to Users and Settings. Continue?'
      )
      if (!ok) return
    }

    setUpdatingId(profile.id)
    const { error } = await supabase.from('profiles').update({ role }).eq('id', profile.id)
    setUpdatingId(null)
    if (error) {
      toast.error(error.message)
      return
    }
    toast.success(`Updated ${profile.email || profile.name || profile.id} → ${role}`)
    await queryClient.invalidateQueries({ queryKey: ['profiles-admin'] })
  }

  const columns: ColumnDef<ProfileRow>[] = useMemo(
    () => [
      {
        id: 'email',
        header: 'Email',
        cell: ({ row }) => row.original.email || '—',
      },
      {
        id: 'name',
        header: 'Name',
        cell: ({ row }) => row.original.name || '—',
      },
      {
        id: 'role',
        header: 'Role',
        cell: ({ row }) => {
          const p = row.original
          return (
            <select
              className="flex h-9 rounded-lg border border-border bg-surface px-2 text-sm text-ink"
              value={p.role}
              disabled={updatingId === p.id}
              onChange={(e) => void updateRole(p, e.target.value as StaffRole)}
            >
              {ROLES.map((r) => (
                <option key={r} value={r}>
                  {r}
                </option>
              ))}
            </select>
          )
        },
      },
      {
        id: 'you',
        header: '',
        cell: ({ row }) =>
          row.original.id === session.user.id ? <Badge variant="success">You</Badge> : null,
      },
      {
        id: 'created',
        header: 'Joined',
        cell: ({ row }) => new Date(row.original.created_at).toLocaleDateString(),
      },
    ],
    [session.user.id, updatingId, adminCount]
  )

  return (
    <div>
      <PageHeader
        title="Users & roles"
        description="Promote staff to editor or admin. Only admins can manage roles and app settings."
      />

      <div className="mt-4 max-w-md">
        <Label htmlFor="users-search">Search</Label>
        <Input
          id="users-search"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          placeholder="Email, name, role…"
        />
      </div>

      <div className="mt-6">
        {isLoading ? (
          <p className="text-sm text-ink-muted">Loading…</p>
        ) : (
          <DataTable
            data={filtered}
            columns={columns}
            rowId={(row) => row.id}
            emptyMessage="No profiles found."
          />
        )}
      </div>
    </div>
  )
}
