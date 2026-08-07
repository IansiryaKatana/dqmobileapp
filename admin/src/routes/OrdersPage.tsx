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
import { ORDER_STATUSES, type OrderRow } from '@/lib/types'

const routeApi = getRouteApi('/_admin/orders')

function formatPence(pence: number) {
  return `£${(pence / 100).toFixed(2)}`
}

function formatAddress(address: OrderRow['address']) {
  if (!address || typeof address !== 'object') return '—'
  const lines = [
    address.name,
    address.line1,
    address.line2,
    [address.city, address.region].filter(Boolean).join(', '),
    address.postcode,
    address.country,
    address.phone,
  ].filter(Boolean)
  return lines.length ? lines.join('\n') : JSON.stringify(address, null, 2)
}

export function OrdersPage() {
  const queryClient = useQueryClient()
  const search = routeApi.useSearch()
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState(search.status ?? '')
  const [selected, setSelected] = useState<OrderRow | null>(null)
  const [statusDraft, setStatusDraft] = useState('')
  const [saving, setSaving] = useState(false)

  const filters = useMemo(() => {
    if (!statusFilter) return []
    if (statusFilter === 'open') {
      return [{ column: 'status', op: 'in' as const, value: ['pending', 'paid', 'processing'] }]
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
  } = usePaginatedQuery<OrderRow>({
    queryKey: ['orders-admin'],
    table: 'orders',
    select: 'id, reference, quantity, language, status, postage_pence, address, created_at, user_id',
    order: { column: 'created_at', ascending: false },
    filters,
    search: searchTerm,
    searchColumns: ['reference', 'language', 'status'],
  })

  const columns: ColumnDef<OrderRow>[] = useMemo(
    () => [
      { header: 'Reference', accessorKey: 'reference' },
      { header: 'Qty', accessorKey: 'quantity' },
      { header: 'Language', accessorKey: 'language' },
      {
        id: 'status',
        header: 'Status',
        cell: ({ row }) => <Badge variant="secondary">{row.original.status}</Badge>,
      },
      {
        id: 'postage',
        header: 'Postage',
        cell: ({ row }) => formatPence(row.original.postage_pence),
      },
      {
        id: 'created',
        header: 'Created',
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

  async function saveStatus() {
    if (!selected) return
    setSaving(true)
    const { error } = await supabase
      .from('orders')
      .update({ status: statusDraft })
      .eq('id', selected.id)
    setSaving(false)
    if (error) {
      toast.error(error.message)
      return
    }
    toast.success('Order status updated')
    setSelected({ ...selected, status: statusDraft })
    await queryClient.invalidateQueries({ queryKey: ['orders-admin'] })
    await queryClient.invalidateQueries({ queryKey: ['dashboard-stats'] })
  }

  return (
    <div>
      <PageHeader title="Orders" description="Fulfill free Quran order requests from the app." />

      <div className="mt-4 flex flex-col gap-3 sm:flex-row sm:items-end">
        <div className="flex-1">
          <Label htmlFor="order-search">Search</Label>
          <Input
            id="order-search"
            value={searchTerm}
            onChange={(e) => {
              setSearchTerm(e.target.value)
              setPageIndex(0)
            }}
            placeholder="Reference, language, status…"
          />
        </div>
        <div className="sm:w-48">
          <Label htmlFor="order-status-filter">Status</Label>
          <select
            id="order-status-filter"
            className="flex h-10 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm text-ink"
            value={statusFilter}
            onChange={(e) => {
              setStatusFilter(e.target.value)
              setPageIndex(0)
            }}
          >
            <option value="">All</option>
            <option value="open">Open (pending/paid/processing)</option>
            {ORDER_STATUSES.map((s) => (
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
            emptyMessage="No orders yet."
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
            <SheetTitle>Order {selected?.reference}</SheetTitle>
            <SheetDescription>Update fulfillment status and review shipping details.</SheetDescription>
          </SheetHeader>
          {selected && (
            <div className="mt-6 space-y-4 text-sm">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <p className="text-ink-muted">Quantity</p>
                  <p className="font-medium text-ink">{selected.quantity}</p>
                </div>
                <div>
                  <p className="text-ink-muted">Language</p>
                  <p className="font-medium text-ink">{selected.language}</p>
                </div>
                <div>
                  <p className="text-ink-muted">Postage</p>
                  <p className="font-medium text-ink">{formatPence(selected.postage_pence)}</p>
                </div>
                <div>
                  <p className="text-ink-muted">Created</p>
                  <p className="font-medium text-ink">{new Date(selected.created_at).toLocaleString()}</p>
                </div>
              </div>
              <div>
                <p className="text-ink-muted">User ID</p>
                <p className="break-all font-mono text-xs text-ink">{selected.user_id ?? '—'}</p>
              </div>
              <div>
                <Label htmlFor="order-status">Status</Label>
                <select
                  id="order-status"
                  className="mt-1 flex h-10 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm text-ink"
                  value={statusDraft}
                  onChange={(e) => setStatusDraft(e.target.value)}
                >
                  {ORDER_STATUSES.map((s) => (
                    <option key={s} value={s}>
                      {s}
                    </option>
                  ))}
                  {!ORDER_STATUSES.includes(statusDraft as (typeof ORDER_STATUSES)[number]) && statusDraft && (
                    <option value={statusDraft}>{statusDraft} (current)</option>
                  )}
                </select>
              </div>
              <div>
                <p className="mb-1 text-ink-muted">Address</p>
                <pre className="whitespace-pre-wrap rounded-lg border border-border bg-cream-dark/40 p-3 text-xs text-ink">
                  {formatAddress(selected.address)}
                </pre>
              </div>
              <SheetFooter>
                <Button type="button" variant="outline" onClick={() => setSelected(null)}>
                  Close
                </Button>
                <Button type="button" disabled={saving || statusDraft === selected.status} onClick={() => void saveStatus()}>
                  {saving ? 'Saving…' : 'Update status'}
                </Button>
              </SheetFooter>
            </div>
          )}
        </SheetContent>
      </Sheet>
    </div>
  )
}
