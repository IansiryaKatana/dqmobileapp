import { useMemo, useState } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import type { ColumnDef } from '@tanstack/react-table'
import { Pencil } from 'lucide-react'
import { toast } from 'sonner'
import { DataTable } from '@/components/DataTable'
import { TopicFormSheet } from '@/components/TopicFormSheet'
import { BulkActionBar, PageHeader } from '@/components/PageHeader'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
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
import type { QuranTopic } from '@/lib/types'

export function TopicsPage() {
  const queryClient = useQueryClient()
  const [sheetOpen, setSheetOpen] = useState(false)
  const [editing, setEditing] = useState<QuranTopic | null>(null)
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set())
  const [deleteOpen, setDeleteOpen] = useState(false)

  const { data = [], isLoading } = useQuery({
    queryKey: ['quran-topics'],
    queryFn: async () => {
      const { data, error } = await supabase.from('quran_topics').select('*').order('sort_order')
      if (error) throw error
      return data as QuranTopic[]
    },
  })

  const columns: ColumnDef<QuranTopic>[] = useMemo(
    () => [
      { header: 'Name', accessorKey: 'name' },
      { header: 'Description', accessorKey: 'description' },
      {
        id: 'surahs',
        header: 'Surahs',
        cell: ({ row }) => row.original.surah_numbers.join(', '),
      },
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

  async function bulkUpdate(published: boolean) {
    const ids = [...selectedIds]
    const { error } = await supabase.from('quran_topics').update({ published }).in('id', ids)
    if (error) {
      toast.error(error.message)
      return
    }
    toast.success(`Updated ${ids.length} topic(s)`)
    setSelectedIds(new Set())
    await queryClient.invalidateQueries({ queryKey: ['quran-topics'] })
  }

  async function bulkDelete() {
    const ids = [...selectedIds]
    const { error } = await supabase.from('quran_topics').delete().in('id', ids)
    if (error) {
      toast.error(error.message)
      return
    }
    toast.success(`Deleted ${ids.length} topic(s)`)
    setSelectedIds(new Set())
    setDeleteOpen(false)
    await queryClient.invalidateQueries({ queryKey: ['quran-topics'] })
  }

  return (
    <div>
      <PageHeader title="Quran Topics" description="Topic chips on the Quran tab in the mobile app.">
        <Button
          type="button"
          size="sm"
          onClick={() => {
            setEditing(null)
            setSheetOpen(true)
          }}
        >
          Add new topic
        </Button>
      </PageHeader>

      <div className="mt-6 flex flex-col gap-4">
        <BulkActionBar count={selectedIds.size} onClear={() => setSelectedIds(new Set())}>
          <Button type="button" size="sm" variant="secondary" onClick={() => bulkUpdate(true)}>Publish</Button>
          <Button type="button" size="sm" variant="secondary" onClick={() => bulkUpdate(false)}>Hide</Button>
          <Button type="button" size="sm" variant="destructive" onClick={() => setDeleteOpen(true)}>Delete</Button>
        </BulkActionBar>

        {isLoading ? (
          <p className="text-sm text-ink-muted">Loading…</p>
        ) : (
          <DataTable
            data={data}
            columns={columns}
            emptyMessage="No topics yet. Add your first Quran topic."
            selectable
            rowId={(row) => row.id}
            selectedIds={selectedIds}
            onSelectedIdsChange={setSelectedIds}
          />
        )}
      </div>

      <TopicFormSheet open={sheetOpen} onOpenChange={setSheetOpen} item={editing} />

      <AlertDialog open={deleteOpen} onOpenChange={setDeleteOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete {selectedIds.size} topics?</AlertDialogTitle>
            <AlertDialogDescription>This cannot be undone.</AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={() => void bulkDelete()}>Delete</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
