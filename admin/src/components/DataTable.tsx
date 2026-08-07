import {

  flexRender,

  getCoreRowModel,

  getPaginationRowModel,

  useReactTable,

  type ColumnDef,

  type PaginationState,

  type RowSelectionState,

} from '@tanstack/react-table'

import { useEffect, useMemo, useRef, useState } from 'react'

import { Checkbox } from '@/components/ui/checkbox'

import { TablePagination } from '@/components/TablePagination'

import { cn } from '@/lib/utils'



type Props<T> = {

  data: T[]

  columns: ColumnDef<T, unknown>[]

  emptyMessage?: string

  selectable?: boolean

  rowId: (row: T) => string

  selectedIds?: Set<string>

  onSelectedIdsChange?: (ids: Set<string>) => void

  pageSize?: number

  manualPagination?: boolean

  pageIndex?: number

  pageCount?: number

  totalCount?: number

  onPageChange?: (pageIndex: number) => void

  onPageSizeChange?: (pageSize: number) => void

}



function selectionKey(ids: Iterable<string>) {

  return [...ids].sort().join('\0')

}



export function DataTable<T>({

  data,

  columns,

  emptyMessage = 'No rows',

  selectable = false,

  rowId,

  selectedIds,

  onSelectedIdsChange,

  pageSize: pageSizeProp = 10,

  manualPagination = false,

  pageIndex: pageIndexProp = 0,

  pageCount: pageCountProp,

  totalCount: totalCountProp,

  onPageChange,

  onPageSizeChange,

}: Props<T>) {

  const [rowSelection, setRowSelection] = useState<RowSelectionState>({})

  const [pagination, setPagination] = useState<PaginationState>({

    pageIndex: 0,

    pageSize: pageSizeProp,

  })

  const lastEmittedKeyRef = useRef('')



  useEffect(() => {

    setPagination((prev) => ({ ...prev, pageSize: pageSizeProp }))

  }, [pageSizeProp])



  useEffect(() => {

    if (manualPagination) {

      setPagination((prev) => ({ ...prev, pageIndex: pageIndexProp }))

    }

  }, [manualPagination, pageIndexProp])



  const selectionColumn: ColumnDef<T, unknown> = useMemo(

    () => ({

      id: 'select',

      header: ({ table }) => (

        <Checkbox

          checked={

            table.getIsAllPageRowsSelected()

              ? true

              : table.getIsSomePageRowsSelected()

                ? 'indeterminate'

                : false

          }

          onCheckedChange={(value) => table.toggleAllPageRowsSelected(value === true)}

          onClick={(e) => e.stopPropagation()}

          aria-label="Select all on page"

        />

      ),

      cell: ({ row }) => (

        <Checkbox

          checked={row.getIsSelected()}

          onCheckedChange={(value) => row.toggleSelected(value === true)}

          onClick={(e) => e.stopPropagation()}

          aria-label="Select row"

        />

      ),

      enableSorting: false,

      enableHiding: false,

      size: 40,

    }),

    []

  )



  const tableColumns = useMemo(

    () => (selectable ? [selectionColumn, ...columns] : columns),

    [selectable, selectionColumn, columns]

  )



  const table = useReactTable({

    data,

    columns: tableColumns,

    getCoreRowModel: getCoreRowModel(),

    getPaginationRowModel: manualPagination ? undefined : getPaginationRowModel(),

    getRowId: (row) => rowId(row),

    enableRowSelection: selectable,

    onRowSelectionChange: setRowSelection,

    manualPagination,

    pageCount: manualPagination ? pageCountProp : undefined,

    onPaginationChange: (updater) => {

      if (manualPagination) {

        const next =

          typeof updater === 'function'

            ? updater({ pageIndex: pageIndexProp, pageSize: pageSizeProp })

            : updater

        if (next.pageIndex !== pageIndexProp) onPageChange?.(next.pageIndex)

        if (next.pageSize !== pageSizeProp) onPageSizeChange?.(next.pageSize)

        return

      }

      setPagination(updater)

    },

    state: {

      rowSelection,

      pagination: manualPagination

        ? { pageIndex: pageIndexProp, pageSize: pageSizeProp }

        : pagination,

    },

  })



  // Push selection up only when it actually changes (avoids render loops).

  useEffect(() => {

    if (!onSelectedIdsChange) return

    const ids = Object.entries(rowSelection)

      .filter(([, selected]) => selected)

      .map(([id]) => id)

    const key = selectionKey(ids)

    if (key === lastEmittedKeyRef.current) return

    lastEmittedKeyRef.current = key

    onSelectedIdsChange(new Set(ids))

  }, [rowSelection, onSelectedIdsChange])



  // Parent cleared selection (bulk bar "Clear selection").

  useEffect(() => {

    if (!selectedIds || selectedIds.size > 0) return

    lastEmittedKeyRef.current = ''

    setRowSelection((prev) => (Object.keys(prev).length === 0 ? prev : {}))

  }, [selectedIds])



  const totalCount = manualPagination ? (totalCountProp ?? 0) : data.length

  const pageCount = manualPagination ? (pageCountProp ?? 1) : table.getPageCount()

  const pageIndex = manualPagination ? pageIndexProp : table.getState().pagination.pageIndex

  const pageSize = manualPagination ? pageSizeProp : table.getState().pagination.pageSize



  if (totalCount === 0 && data.length === 0) {

    return (

      <div className="rounded-xl border border-dashed border-border bg-surface px-6 py-12 text-center">

        <p className="text-sm text-ink-muted">{emptyMessage}</p>

      </div>

    )

  }



  return (

    <div className="overflow-hidden rounded-xl border border-border bg-surface shadow-sm">

      <div className="overflow-x-auto">

        <table className="min-w-full text-left text-sm">

          <thead className="border-b border-border bg-cream-dark/60 text-ink-muted">

            {table.getHeaderGroups().map((hg) => (

              <tr key={hg.id}>

                {hg.headers.map((h) => (

                  <th

                    key={h.id}

                    className={cn(

                      'whitespace-nowrap px-2 py-2.5 text-xs font-medium sm:px-4 sm:py-3 sm:text-sm',

                      h.id === 'select' && 'w-10'

                    )}

                  >

                    {flexRender(h.column.columnDef.header, h.getContext())}

                  </th>

                ))}

              </tr>

            ))}

          </thead>

          <tbody>

            {table.getRowModel().rows.map((row) => (

              <tr

                key={row.id}

                className={cn(

                  'border-t border-border transition-colors hover:bg-cream/80',

                  row.getIsSelected() && 'bg-accent-soft/40'

                )}

              >

                {row.getVisibleCells().map((cell) => (

                  <td

                    key={cell.id}

                    className={cn(

                      'px-2 py-2.5 text-xs text-ink sm:px-4 sm:py-3 sm:text-sm',

                      cell.column.id === 'select' && 'w-10'

                    )}

                  >

                    {flexRender(cell.column.columnDef.cell, cell.getContext())}

                  </td>

                ))}

              </tr>

            ))}

          </tbody>

        </table>

      </div>

      <TablePagination

        pageIndex={pageIndex}

        pageCount={Math.max(1, pageCount)}

        totalCount={totalCount}

        pageSize={pageSize}

        onPageChange={(next) => {

          if (manualPagination) onPageChange?.(next)

          else table.setPageIndex(next)

        }}

        onPageSizeChange={(next) => {

          if (manualPagination) onPageSizeChange?.(next)

          else table.setPageSize(next)

        }}

      />

    </div>

  )

}


