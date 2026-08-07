import { useMemo, useState } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import type { ColumnDef } from '@tanstack/react-table'
import { Pencil, Plus, Trash2 } from 'lucide-react'
import { toast } from 'sonner'
import { DataTable } from '@/components/DataTable'
import { PageHeader } from '@/components/PageHeader'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Sheet, SheetContent, SheetHeader, SheetTitle } from '@/components/ui/sheet'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import { supabase } from '@/lib/supabase'

type NavItem = {
  id: string
  section: string
  label: string
  route: string
  icon: string
  subtitle: string | null
  badge: string | null
  published: boolean
  sort_order: number
}

const SECTIONS = ['featured', 'actions', 'learn', 'support', 'account'] as const

/** Keys used by lib/core/services/navigation_repository.dart */
const ICON_OPTIONS = [
  'mosque',
  'volunteer_activism',
  'local_shipping',
  'help_outline',
  'storefront',
  'public',
  'water_drop',
  'menu_book',
  'quiz',
  'support_agent',
  'info',
  'settings',
  'language',
  'privacy_tip',
  'description',
  'history',
  'receipt',
  'bookmark',
  'notifications',
  'location',
  'self_improvement',
  'question_answer',
  'chevron_right',
]

export function NavigationPage() {
  const queryClient = useQueryClient()
  const [tab, setTab] = useState<string>('actions')
  const [sheetOpen, setSheetOpen] = useState(false)
  const [editing, setEditing] = useState<NavItem | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<NavItem | null>(null)
  const [form, setForm] = useState({
    label: '',
    route: '',
    icon: 'chevron_right',
    subtitle: '',
    badge: '',
    sort_order: 0,
    published: true,
  })

  const { data = [], isLoading } = useQuery({
    queryKey: ['navigation-menu'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('navigation_menu_items')
        .select('*')
        .order('section')
        .order('sort_order')
      if (error) throw error
      return data as NavItem[]
    },
  })

  const columns: ColumnDef<NavItem>[] = useMemo(
    () => [
      { header: 'Label', accessorKey: 'label' },
      { header: 'Route', accessorKey: 'route' },
      { header: 'Icon', accessorKey: 'icon' },
      {
        id: 'published',
        header: 'Status',
        cell: ({ row }) => (
          <Badge variant={row.original.published ? 'success' : 'draft'}>
            {row.original.published ? 'Published' : 'Hidden'}
          </Badge>
        ),
      },
      {
        id: 'actions',
        header: 'Actions',
        cell: ({ row }) => (
          <div className="flex gap-1">
            <Button type="button" variant="ghost" size="sm" onClick={() => openEdit(row.original)}>
              <Pencil className="size-3.5" />
              Edit
            </Button>
            <Button
              type="button"
              variant="ghost"
              size="sm"
              className="text-danger hover:text-danger"
              onClick={() => setDeleteTarget(row.original)}
            >
              <Trash2 className="size-3.5" />
              Delete
            </Button>
          </div>
        ),
      },
    ],
    []
  )

  function openNew(section: string) {
    setEditing(null)
    setForm({
      label: '',
      route: '/',
      icon: 'chevron_right',
      subtitle: '',
      badge: section === 'featured' ? 'Featured Guide' : '',
      sort_order: data.filter((d) => d.section === section).length + 1,
      published: true,
    })
    setSheetOpen(true)
  }

  function openEdit(item: NavItem) {
    setEditing(item)
    setForm({
      label: item.label,
      route: item.route,
      icon: item.icon,
      subtitle: item.subtitle ?? '',
      badge: item.badge ?? '',
      sort_order: item.sort_order,
      published: item.published,
    })
    setSheetOpen(true)
  }

  async function save() {
    const payload = {
      section: editing?.section ?? tab,
      label: form.label,
      route: form.route,
      icon: form.icon,
      subtitle: form.subtitle || null,
      badge: form.badge || null,
      sort_order: form.sort_order,
      published: form.published,
      updated_at: new Date().toISOString(),
    }
    const { error } = editing
      ? await supabase.from('navigation_menu_items').update(payload).eq('id', editing.id)
      : await supabase.from('navigation_menu_items').insert(payload)
    if (error) {
      toast.error(error.message)
      return
    }
    toast.success(editing ? 'Menu item updated' : 'Menu item added')
    setSheetOpen(false)
    await queryClient.invalidateQueries({ queryKey: ['navigation-menu'] })
  }

  async function confirmDelete() {
    if (!deleteTarget) return
    const { error } = await supabase.from('navigation_menu_items').delete().eq('id', deleteTarget.id)
    if (error) {
      toast.error(error.message)
      return
    }
    toast.success('Menu item deleted')
    setDeleteTarget(null)
    await queryClient.invalidateQueries({ queryKey: ['navigation-menu'] })
  }

  return (
    <div>
      <PageHeader
        title="More menu"
        description="Manage More tab sections, routes, and Material icon keys shown in the mobile app."
      />
      <Tabs value={tab} onValueChange={setTab} className="mt-6">
        <TabsList>
          {SECTIONS.map((s) => (
            <TabsTrigger key={s} value={s} className="capitalize">
              {s}
            </TabsTrigger>
          ))}
        </TabsList>
        {SECTIONS.map((section) => (
          <TabsContent key={section} value={section}>
            <div className="mb-4 flex justify-end">
              <Button type="button" size="sm" onClick={() => openNew(section)}>
                <Plus className="size-3.5" />
                Add item
              </Button>
            </div>
            {isLoading ? (
              <p className="text-sm text-ink-muted">Loading…</p>
            ) : (
              <DataTable
                data={data.filter((d) => d.section === section)}
                columns={columns}
                rowId={(row) => row.id}
                emptyMessage={`No items in ${section}.`}
              />
            )}
          </TabsContent>
        ))}
      </Tabs>

      <Sheet open={sheetOpen} onOpenChange={setSheetOpen}>
        <SheetContent className="overflow-y-auto">
          <SheetHeader>
            <SheetTitle>{editing ? 'Edit menu item' : 'New menu item'}</SheetTitle>
          </SheetHeader>
          <div className="mt-6 space-y-4">
            <div>
              <Label>Label</Label>
              <Input value={form.label} onChange={(e) => setForm({ ...form, label: e.target.value })} />
            </div>
            <div>
              <Label>Route</Label>
              <Input
                value={form.route}
                onChange={(e) => setForm({ ...form, route: e.target.value })}
                placeholder="/donate"
              />
            </div>
            <div>
              <Label>Icon key</Label>
              <select
                className="flex h-10 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm text-ink"
                value={form.icon}
                onChange={(e) => setForm({ ...form, icon: e.target.value })}
              >
                {ICON_OPTIONS.map((icon) => (
                  <option key={icon} value={icon}>
                    {icon}
                  </option>
                ))}
                {!ICON_OPTIONS.includes(form.icon) && form.icon && (
                  <option value={form.icon}>{form.icon}</option>
                )}
              </select>
            </div>
            {(editing?.section === 'featured' || tab === 'featured') && (
              <>
                <div>
                  <Label>Subtitle (featured card)</Label>
                  <Input value={form.subtitle} onChange={(e) => setForm({ ...form, subtitle: e.target.value })} />
                </div>
                <div>
                  <Label>Badge (featured card)</Label>
                  <Input value={form.badge} onChange={(e) => setForm({ ...form, badge: e.target.value })} />
                </div>
              </>
            )}
            <div>
              <Label>Sort order</Label>
              <Input
                type="number"
                value={form.sort_order}
                onChange={(e) => setForm({ ...form, sort_order: Number(e.target.value) })}
              />
            </div>
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={form.published}
                onChange={(e) => setForm({ ...form, published: e.target.checked })}
              />
              Published
            </label>
            <Button type="button" onClick={() => void save()}>
              Save
            </Button>
          </div>
        </SheetContent>
      </Sheet>

      <AlertDialog open={!!deleteTarget} onOpenChange={(open) => !open && setDeleteTarget(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete “{deleteTarget?.label}”?</AlertDialogTitle>
            <AlertDialogDescription>
              This removes the item from the More menu. This cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={() => void confirmDelete()}>Delete</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
