import { ChevronLeft, ChevronRight } from 'lucide-react'
import { Button } from '@/components/ui/button'

type Props = {
  pageIndex: number
  pageCount: number
  totalCount: number
  pageSize: number
  onPageChange: (pageIndex: number) => void
  onPageSizeChange?: (pageSize: number) => void
}

const PAGE_SIZE_OPTIONS = [10, 25, 50]

export function TablePagination({
  pageIndex,
  pageCount,
  totalCount,
  pageSize,
  onPageChange,
  onPageSizeChange,
}: Props) {
  if (totalCount === 0) return null

  const from = pageIndex * pageSize + 1
  const to = Math.min((pageIndex + 1) * pageSize, totalCount)
  const canPrev = pageIndex > 0
  const canNext = pageIndex < pageCount - 1

  return (
    <div className="flex flex-col gap-3 border-t border-border px-3 py-3 sm:flex-row sm:items-center sm:justify-between sm:px-4">
      <p className="text-center text-xs text-ink-muted sm:text-left sm:text-sm">
        {from}–{to} of {totalCount}
      </p>
      <div className="flex flex-wrap items-center justify-center gap-2 sm:justify-end">
        {onPageSizeChange && (
          <label className="flex items-center gap-2 text-xs text-ink-muted sm:text-sm">
            Rows
            <select
              value={pageSize}
              onChange={(e) => onPageSizeChange(Number(e.target.value))}
              className="h-8 rounded-lg border border-border bg-surface px-2 text-sm text-ink"
            >
              {PAGE_SIZE_OPTIONS.map((size) => (
                <option key={size} value={size}>
                  {size}
                </option>
              ))}
            </select>
          </label>
        )}
        <Button
          type="button"
          variant="outline"
          size="sm"
          disabled={!canPrev}
          onClick={() => onPageChange(pageIndex - 1)}
        >
          <ChevronLeft className="size-4" />
          <span className="hidden sm:inline">Previous</span>
        </Button>
        <span className="min-w-[4.5rem] text-center text-xs text-ink-muted sm:text-sm">
          {pageIndex + 1} / {pageCount}
        </span>
        <Button
          type="button"
          variant="outline"
          size="sm"
          disabled={!canNext}
          onClick={() => onPageChange(pageIndex + 1)}
        >
          <span className="hidden sm:inline">Next</span>
          <ChevronRight className="size-4" />
        </Button>
      </div>
    </div>
  )
}
