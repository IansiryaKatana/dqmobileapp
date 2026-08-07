import { useQuery } from '@tanstack/react-query'
import { useState } from 'react'
import { supabase } from '@/lib/supabase'

type OrderConfig = {
  column: string
  ascending?: boolean
}

type FilterConfig =
  | { column: string; op: 'eq'; value: string }
  | { column: string; op: 'in'; value: string[] }
  | { column: string; op: 'ilike'; value: string }

type Options = {
  queryKey: string[]
  table: string
  select: string
  order: OrderConfig
  pageSize?: number
  filters?: FilterConfig[]
  search?: string
  searchColumns?: string[]
}

export function usePaginatedQuery<T>({
  queryKey,
  table,
  select,
  order,
  pageSize: initialPageSize = 10,
  filters = [],
  search = '',
  searchColumns = [],
}: Options) {
  const [pageIndex, setPageIndex] = useState(0)
  const [pageSize, setPageSize] = useState(initialPageSize)

  const query = useQuery({
    queryKey: [...queryKey, pageIndex, pageSize, filters, search, searchColumns],
    queryFn: async () => {
      const from = pageIndex * pageSize
      const to = from + pageSize - 1

      let q = supabase
        .from(table)
        .select(select, { count: 'exact' })
        .order(order.column, { ascending: order.ascending ?? false })

      for (const f of filters) {
        if (f.op === 'eq') q = q.eq(f.column, f.value)
        else if (f.op === 'in') q = q.in(f.column, f.value)
        else if (f.op === 'ilike') q = q.ilike(f.column, f.value)
      }

      const term = search.trim()
      if (term && searchColumns.length > 0) {
        const or = searchColumns.map((c) => `${c}.ilike.%${term}%`).join(',')
        q = q.or(or)
      }

      const { data, error, count } = await q.range(from, to)

      if (error) throw error
      return {
        rows: (data ?? []) as T[],
        total: count ?? 0,
      }
    },
  })

  const total = query.data?.total ?? 0
  const pageCount = Math.max(1, Math.ceil(total / pageSize))

  function setPageIndexSafe(next: number) {
    setPageIndex(Math.max(0, Math.min(next, pageCount - 1)))
  }

  function setPageSizeSafe(next: number) {
    setPageSize(next)
    setPageIndex(0)
  }

  return {
    rows: query.data?.rows ?? [],
    total,
    pageIndex,
    pageCount,
    pageSize,
    isLoading: query.isLoading,
    setPageIndex: setPageIndexSafe,
    setPageSize: setPageSizeSafe,
    refetch: query.refetch,
  }
}
