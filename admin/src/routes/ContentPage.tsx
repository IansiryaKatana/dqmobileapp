import { useMemo, useState } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import type { ColumnDef } from '@tanstack/react-table'
import { Pencil, RefreshCw } from 'lucide-react'
import { toast } from 'sonner'
import { DataTable } from '@/components/DataTable'
import { ContentFormSheet } from '@/components/ContentFormSheet'
import { BulkActionBar, PageHeader } from '@/components/PageHeader'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
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
import { CONTENT_KINDS, CONTENT_KIND_META, type ContentKind } from '@/lib/content'
import { supabase } from '@/lib/supabase'
import type { ContentItem } from '@/lib/types'

function KindPanel({ kind }: { kind: ContentKind }) {
  const queryClient = useQueryClient()
  const meta = CONTENT_KIND_META[kind]
  const [sheetOpen, setSheetOpen] = useState(false)
  const [editing, setEditing] = useState<ContentItem | null>(null)
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set())
  const [deleteOpen, setDeleteOpen] = useState(false)

  const { data = [], isLoading, refetch } = useQuery({
    queryKey: ['content-items', kind],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('content_items')
        .select('*')
        .eq('kind', kind)
        .order('sort_order')
      if (error) throw error
      return data as ContentItem[]
    },
  })

  const columns: ColumnDef<ContentItem>[] = useMemo(
    () => [
      { header: 'Title', accessorKey: 'title' },
      { header: 'Topic', accessorKey: 'topic' },
      {
        id: 'published',
        header: 'Status',
        cell: ({ row }) => (
          <Badge variant={row.original.published ? 'success' : 'draft'}>
            {row.original.published ? 'Published' : 'Draft'}
          </Badge>
        ),
      },
      {
        id: 'actions',
        header: 'Actions',
        cell: ({ row }) => (
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={() => {
              setEditing(row.original)
              setSheetOpen(true)
            }}
          >
            <Pencil className="size-3.5 shrink-0" />
            <span className="hidden sm:inline">Edit</span>
          </Button>
        ),
      },
    ],
    []
  )

  async function bulkUpdate(field: 'published', value: boolean) {
    const ids = [...selectedIds]
    if (ids.length === 0) return
    const { error } = await supabase
      .from('content_items')
      .update({ [field]: value, updated_at: new Date().toISOString() })
      .in('id', ids)
    if (error) {
      toast.error(error.message)
      return
    }
    toast.success(value ? `Published ${ids.length} item(s)` : `Moved ${ids.length} item(s) to draft`)
    setSelectedIds(new Set())
    await queryClient.invalidateQueries({ queryKey: ['content-items'] })
  }

  async function bulkDelete() {
    const ids = [...selectedIds]
    const { error } = await supabase.from('content_items').delete().in('id', ids)
    if (error) {
      toast.error(error.message)
      return
    }
    toast.success(`Deleted ${ids.length} ${meta.plural.toLowerCase()}`)
    setSelectedIds(new Set())
    setDeleteOpen(false)
    await queryClient.invalidateQueries({ queryKey: ['content-items'] })
  }

  return (
    <>
      <PageHeader title={meta.plural} description={meta.description}>
        <Button type="button" variant="outline" size="sm" onClick={() => refetch()}>
          <RefreshCw className="size-3.5" />
          Refresh
        </Button>
        <Button
          type="button"
          size="sm"
          onClick={() => {
            setEditing(null)
            setSheetOpen(true)
          }}
        >
          {meta.addLabel}
        </Button>
      </PageHeader>

      <div className="mt-4 flex flex-col gap-4">
        <BulkActionBar count={selectedIds.size} onClear={() => setSelectedIds(new Set())}>
          <Button type="button" size="sm" variant="secondary" onClick={() => bulkUpdate('published', true)}>
            Publish
          </Button>
          <Button type="button" size="sm" variant="secondary" onClick={() => bulkUpdate('published', false)}>
            Unpublish
          </Button>
          <Button type="button" size="sm" variant="destructive" onClick={() => setDeleteOpen(true)}>
            Delete
          </Button>
        </BulkActionBar>

        {isLoading ? (
          <p className="text-sm text-ink-muted">Loading…</p>
        ) : (
          <DataTable
            data={data}
            columns={columns}
            emptyMessage={`No ${meta.plural.toLowerCase()} yet. ${meta.addLabel} to get started.`}
            selectable
            rowId={(row) => row.id}
            selectedIds={selectedIds}
            onSelectedIdsChange={setSelectedIds}
          />
        )}
      </div>

      <ContentFormSheet
        open={sheetOpen}
        onOpenChange={setSheetOpen}
        item={editing}
        kind={kind}
        onSaved={() => setEditing(null)}
      />

      <AlertDialog open={deleteOpen} onOpenChange={setDeleteOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete {selectedIds.size} {meta.plural.toLowerCase()}?</AlertDialogTitle>
            <AlertDialogDescription>
              This cannot be undone. Selected items will be permanently removed from the app.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={() => void bulkDelete()}>Delete</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  )
}

export function ContentPage() {
  const [tab, setTab] = useState<ContentKind>('article')

  return (
    <div>
      <PageHeader
        title="Content"
        description="Manage articles, books, and campaigns served to the mobile app."
      />
      <Tabs value={tab} onValueChange={(v) => setTab(v as ContentKind)} className="mt-6">
        <TabsList>
          {CONTENT_KINDS.map((kind) => (
            <TabsTrigger key={kind} value={kind}>
              {CONTENT_KIND_META[kind].plural}
            </TabsTrigger>
          ))}
        </TabsList>
        {CONTENT_KINDS.map((kind) => (
          <TabsContent key={kind} value={kind}>
            {kind === 'campaign' && (
              <p className="mb-4 rounded-lg border border-border bg-cream-dark/50 px-3 py-2 text-sm text-ink-muted">
                Home Featured Campaign is driven by{' '}
                <span className="font-medium text-ink">App Settings → home_campaign</span>, not these{' '}
                <code>content_items</code> campaign rows.
              </p>
            )}
            <KindPanel kind={kind} />
          </TabsContent>
        ))}
      </Tabs>
    </div>
  )
}
