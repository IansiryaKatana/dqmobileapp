import { useMemo, useState } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { getRouteApi } from '@tanstack/react-router'
import type { ColumnDef } from '@tanstack/react-table'
import { Eye } from 'lucide-react'
import { toast } from 'sonner'
import { DataTable } from '@/components/DataTable'
import { PageHeader } from '@/components/PageHeader'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetFooter,
  SheetHeader,
  SheetTitle,
} from '@/components/ui/sheet'
import { usePaginatedQuery } from '@/lib/usePaginatedQuery'
import { supabase } from '@/lib/supabase'
import { SCHOLAR_STATUSES, type ScholarQuestionRow } from '@/lib/types'

const routeApi = getRouteApi('/_admin/scholar')

export function ScholarPage() {
  const queryClient = useQueryClient()
  const search = routeApi.useSearch()
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState(search.status ?? '')
  const [selected, setSelected] = useState<ScholarQuestionRow | null>(null)
  const [statusDraft, setStatusDraft] = useState('')
  const [answerDraft, setAnswerDraft] = useState('')
  const [saving, setSaving] = useState(false)

  const filters = useMemo(() => {
    if (!statusFilter) return []
    if (statusFilter === 'open') {
      return [{ column: 'status', op: 'in' as const, value: ['submitted', 'in_review'] }]
    }
    return [{ column: 'status', op: 'eq' as const, value: statusFilter }]
  }, [statusFilter])

  const {
    rows,
    total,
    pageIndex,
    pageCount,
    pageSize,
    isLoading,
    setPageIndex,
    setPageSize,
  } = usePaginatedQuery<ScholarQuestionRow>({
    queryKey: ['scholar-admin'],
    table: 'scholar_questions',
    select:
      'id, name, email, topic, question, status, answer, answered_at, answered_by, created_at, user_id',
    order: { column: 'created_at', ascending: false },
    filters,
    search: searchTerm,
    searchColumns: ['name', 'email', 'topic', 'question', 'status'],
  })

  const columns: ColumnDef<ScholarQuestionRow>[] = useMemo(
    () => [
      { header: 'Name', accessorKey: 'name' },
      { header: 'Email', accessorKey: 'email' },
      { header: 'Topic', accessorKey: 'topic' },
      {
        id: 'question',
        header: 'Question',
        cell: ({ row }) => <span className="line-clamp-2 max-w-xs">{row.original.question}</span>,
      },
      {
        id: 'status',
        header: 'Status',
        cell: ({ row }) => <Badge variant="secondary">{row.original.status}</Badge>,
      },
      {
        id: 'submitted',
        header: 'Submitted',
        cell: ({ row }) => new Date(row.original.created_at).toLocaleString(),
      },
      {
        id: 'actions',
        header: '',
        cell: ({ row }) => (
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={() => {
              setSelected(row.original)
              setStatusDraft(row.original.status)
              setAnswerDraft(row.original.answer ?? '')
            }}
          >
            <Eye className="size-3.5" />
            View
          </Button>
        ),
      },
    ],
    []
  )

  async function save() {
    if (!selected) return
    setSaving(true)
    const {
      data: { user },
    } = await supabase.auth.getUser()
    const trimmed = answerDraft.trim()
    const payload: Record<string, unknown> = {
      status: statusDraft,
      answer: trimmed || null,
    }
    if (trimmed) {
      payload.answered_at = new Date().toISOString()
      payload.answered_by = user?.id ?? null
      if (statusDraft === 'submitted' || statusDraft === 'in_review') {
        payload.status = 'answered'
        setStatusDraft('answered')
      }
    } else {
      payload.answered_at = null
      payload.answered_by = null
    }

    const { error } = await supabase.from('scholar_questions').update(payload).eq('id', selected.id)
    setSaving(false)
    if (error) {
      toast.error(error.message)
      return
    }
    toast.success('Question updated')
    setSelected({
      ...selected,
      status: (payload.status as string) ?? statusDraft,
      answer: (payload.answer as string | null) ?? null,
      answered_at: (payload.answered_at as string | null) ?? null,
      answered_by: (payload.answered_by as string | null) ?? null,
    })
    await queryClient.invalidateQueries({ queryKey: ['scholar-admin'] })
    await queryClient.invalidateQueries({ queryKey: ['dashboard-stats'] })
  }

  return (
    <div>
      <PageHeader
        title="Scholar questions"
        description="Triage Ask a Scholar submissions and write in-app answers."
      />

      <div className="mt-4 flex flex-col gap-3 sm:flex-row sm:items-end">
        <div className="flex-1">
          <Label htmlFor="scholar-search">Search</Label>
          <Input
            id="scholar-search"
            value={searchTerm}
            onChange={(e) => {
              setSearchTerm(e.target.value)
              setPageIndex(0)
            }}
            placeholder="Name, email, topic…"
          />
        </div>
        <div className="sm:w-48">
          <Label htmlFor="scholar-status-filter">Status</Label>
          <select
            id="scholar-status-filter"
            className="flex h-10 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm text-ink"
            value={statusFilter}
            onChange={(e) => {
              setStatusFilter(e.target.value)
              setPageIndex(0)
            }}
          >
            <option value="">All</option>
            <option value="open">Open (submitted/in_review)</option>
            {SCHOLAR_STATUSES.map((s) => (
              <option key={s} value={s}>
                {s}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="mt-6">
        {isLoading ? (
          <p className="text-sm text-ink-muted">Loading…</p>
        ) : (
          <DataTable
            data={rows}
            columns={columns}
            rowId={(row) => row.id}
            emptyMessage="No questions yet."
            manualPagination
            pageIndex={pageIndex}
            pageCount={pageCount}
            pageSize={pageSize}
            totalCount={total}
            onPageChange={setPageIndex}
            onPageSizeChange={setPageSize}
          />
        )}
      </div>

      <Sheet open={!!selected} onOpenChange={(open) => !open && setSelected(null)}>
        <SheetContent className="overflow-y-auto sm:max-w-lg">
          <SheetHeader>
            <SheetTitle>{selected?.topic}</SheetTitle>
            <SheetDescription>From {selected?.name} · {selected?.email}</SheetDescription>
          </SheetHeader>
          {selected && (
            <div className="mt-6 space-y-4 text-sm">
              <div>
                <p className="mb-1 text-ink-muted">Question</p>
                <p className="whitespace-pre-wrap rounded-lg border border-border bg-cream-dark/40 p-3 text-ink">
                  {selected.question}
                </p>
              </div>
              <div>
                <p className="text-ink-muted">User ID</p>
                <p className="break-all font-mono text-xs text-ink">{selected.user_id ?? '—'}</p>
              </div>
              <div>
                <Label htmlFor="scholar-status">Status</Label>
                <select
                  id="scholar-status"
                  className="mt-1 flex h-10 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm text-ink"
                  value={statusDraft}
                  onChange={(e) => setStatusDraft(e.target.value)}
                >
                  {SCHOLAR_STATUSES.map((s) => (
                    <option key={s} value={s}>
                      {s}
                    </option>
                  ))}
                  {!SCHOLAR_STATUSES.includes(statusDraft as (typeof SCHOLAR_STATUSES)[number]) &&
                    statusDraft && <option value={statusDraft}>{statusDraft} (current)</option>}
                </select>
              </div>
              <div>
                <Label htmlFor="scholar-answer">Answer (shown in app)</Label>
                <Textarea
                  id="scholar-answer"
                  rows={6}
                  className="mt-1"
                  value={answerDraft}
                  onChange={(e) => setAnswerDraft(e.target.value)}
                  placeholder="Write the scholar reply…"
                />
                {selected.answered_at && (
                  <p className="mt-1 text-xs text-ink-muted">
                    Last answered {new Date(selected.answered_at).toLocaleString()}
                  </p>
                )}
              </div>
              <SheetFooter>
                <Button type="button" variant="outline" onClick={() => setSelected(null)}>
                  Close
                </Button>
                <Button type="button" disabled={saving} onClick={() => void save()}>
                  {saving ? 'Saving…' : 'Save'}
                </Button>
              </SheetFooter>
            </div>
          )}
        </SheetContent>
      </Sheet>
    </div>
  )
}
