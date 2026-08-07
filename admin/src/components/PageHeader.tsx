import type { ReactNode } from 'react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'

type Props = {
  title: string
  description?: string
  children?: ReactNode
}

export function PageHeader({ title, description, children }: Props) {
  return (
    <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
      <div className="min-w-0">
        <h2 className="text-xl font-bold tracking-tight text-ink sm:text-2xl">{title}</h2>
        {description && (
          <p className="mt-1 max-w-2xl text-sm leading-relaxed text-ink-muted">{description}</p>
        )}
      </div>
      {children && (
        <div className="flex w-full flex-col gap-2 sm:w-auto sm:flex-row sm:flex-wrap sm:justify-end [&_button]:w-full sm:[&_button]:w-auto">
          {children}
        </div>
      )}
    </div>
  )
}

type BulkProps = {
  count: number
  onClear: () => void
  children: ReactNode
}

export function BulkActionBar({ count, onClear, children }: BulkProps) {
  if (count === 0) return null
  return (
    <div className="flex flex-col gap-3 rounded-xl border border-accent/30 bg-accent-soft px-3 py-3 sm:flex-row sm:flex-wrap sm:items-center sm:gap-3 sm:px-4">
      <span className="text-sm font-medium text-ink">{count} selected</span>
      <div className="flex flex-wrap items-center gap-2">{children}</div>
      <Button
        type="button"
        variant="ghost"
        size="sm"
        className={cn('w-full sm:ml-auto sm:w-auto')}
        onClick={onClear}
      >
        Clear selection
      </Button>
    </div>
  )
}
