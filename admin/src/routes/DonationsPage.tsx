import { useMemo, useState } from 'react'
import type { ColumnDef } from '@tanstack/react-table'
import { Eye, Mail } from 'lucide-react'
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
import type { DonationRow } from '@/lib/types'

function donorEmail(row: DonationRow) {
  return row.metadata?.donor_email?.trim() || ''
}

function donorName(row: DonationRow) {
  return row.metadata?.donor_name?.trim() || ''
}

export function DonationsPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [selected, setSelected] = useState<DonationRow | null>(null)
  const [resending, setResending] = useState(false)

  const {
    rows,
    total,
    pageIndex,
    pageCount,
    pageSize,
    isLoading,
    setPageIndex,
    setPageSize,
  } = usePaginatedQuery<DonationRow>({
    queryKey: ['donations-admin'],
    table: 'donations',
    select: 'id, amount_pence, currency, frequency, status, receipt_id, created_at, user_id, metadata',
    order: { column: 'created_at', ascending: false },
    search: searchTerm,
    searchColumns: ['receipt_id', 'status', 'currency', 'frequency'],
  })

  const columns: ColumnDef<DonationRow>[] = useMemo(
    () => [
      {
        id: 'amount',
        header: 'Amount',
        cell: ({ row }) =>
          `${(row.original.amount_pence / 100).toFixed(2)} ${row.original.currency.toUpperCase()}`,
      },
      { header: 'Frequency', accessorKey: 'frequency' },
      {
        id: 'status',
        header: 'Status',
        cell: ({ row }) => <Badge variant="secondary">{row.original.status}</Badge>,
      },
      {
        id: 'receipt',
        header: 'Receipt',
        cell: ({ row }) => row.original.receipt_id || '—',
      },
      {
        id: 'donor',
        header: 'Donor',
        cell: ({ row }) => {
          const name = donorName(row.original)
          const email = donorEmail(row.original)
          if (!name && !email) return '—'
          return (
            <span className="line-clamp-2">
              {name || '—'}
              {email ? <span className="block text-xs text-ink-muted">{email}</span> : null}
            </span>
          )
        },
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
          <Button type="button" variant="ghost" size="sm" onClick={() => setSelected(row.original)}>
            <Eye className="size-3.5" />
            View
          </Button>
        ),
      },
    ],
    []
  )

  async function resendEmail() {
    if (!selected) return
    const email = donorEmail(selected)
    if (!email) {
      toast.error('No donor email in metadata — cannot resend')
      return
    }
    setResending(true)
    const { data, error } = await supabase.functions.invoke('donation-email', {
      body: {
        receipt_id: selected.receipt_id ?? undefined,
        amount_pence: selected.amount_pence,
        currency: selected.currency,
        email,
        donor_name: donorName(selected) || undefined,
        status: selected.status,
      },
    })
    setResending(false)
    if (error) {
      toast.error(error.message || 'Failed to invoke donation-email')
      return
    }
    if (data && typeof data === 'object' && 'ok' in data && data.ok === false) {
      toast.error(
        typeof data === 'object' && data && 'message' in data
          ? String((data as { message?: string }).message)
          : 'Email send failed'
      )
      return
    }
    if (data && typeof data === 'object' && 'skipped' in data && data.skipped) {
      toast.message(`Skipped: ${String((data as { reason?: string }).reason ?? 'unknown')}`)
      return
    }
    toast.success('Donation email resent')
  }

  return (
    <div>
      <PageHeader
        title="Donations"
        description="Ops view of donations. Payments are processed via RevenueCat in the mobile app."
      />

      <div className="mt-4 max-w-md">
        <Label htmlFor="donation-search">Search</Label>
        <Input
          id="donation-search"
          value={searchTerm}
          onChange={(e) => {
            setSearchTerm(e.target.value)
            setPageIndex(0)
          }}
          placeholder="Receipt, status, currency…"
        />
      </div>

      <div className="mt-6">
        {isLoading ? (
          <p className="text-sm text-ink-muted">Loading…</p>
        ) : (
          <DataTable
            data={rows}
            columns={columns}
            rowId={(row) => row.id}
            emptyMessage="No donations yet."
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
            <SheetTitle>Donation detail</SheetTitle>
            <SheetDescription>
              {selected
                ? `${(selected.amount_pence / 100).toFixed(2)} ${selected.currency.toUpperCase()}`
                : ''}
            </SheetDescription>
          </SheetHeader>
          {selected && (
            <div className="mt-6 space-y-4 text-sm">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <p className="text-ink-muted">Frequency</p>
                  <p className="font-medium text-ink">{selected.frequency}</p>
                </div>
                <div>
                  <p className="text-ink-muted">Status</p>
                  <p className="font-medium text-ink">{selected.status}</p>
                </div>
                <div>
                  <p className="text-ink-muted">Receipt</p>
                  <p className="font-medium text-ink">{selected.receipt_id || '—'}</p>
                </div>
                <div>
                  <p className="text-ink-muted">Created</p>
                  <p className="font-medium text-ink">{new Date(selected.created_at).toLocaleString()}</p>
                </div>
              </div>
              <div>
                <p className="text-ink-muted">Donor</p>
                <p className="font-medium text-ink">{donorName(selected) || '—'}</p>
                <p className="text-ink-muted">{donorEmail(selected) || '—'}</p>
              </div>
              <div>
                <p className="text-ink-muted">User ID</p>
                <p className="break-all font-mono text-xs text-ink">{selected.user_id ?? '—'}</p>
              </div>
              <div>
                <p className="mb-1 text-ink-muted">Metadata</p>
                <pre className="overflow-x-auto rounded-lg border border-border bg-cream-dark/40 p-3 text-xs text-ink">
                  {JSON.stringify(selected.metadata ?? {}, null, 2)}
                </pre>
              </div>
              <SheetFooter>
                <Button type="button" variant="outline" onClick={() => setSelected(null)}>
                  Close
                </Button>
                <Button type="button" disabled={resending} onClick={() => void resendEmail()}>
                  <Mail className="size-3.5" />
                  {resending ? 'Sending…' : 'Resend email'}
                </Button>
              </SheetFooter>
            </div>
          )}
        </SheetContent>
      </Sheet>
    </div>
  )
}
