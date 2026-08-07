import { useQuery } from '@tanstack/react-query'
import { Link } from '@tanstack/react-router'
import { PageHeader } from '@/components/PageHeader'
import { supabase } from '@/lib/supabase'
import type { ImpactStats } from '@/lib/types'

type Card = {
  label: string
  value: number
  to?: string
  search?: Record<string, string>
  hint?: string
}

const IMPACT_BASELINES = {
  qurans_funded: 875_000,
  orders_placed: 24_561,
  countries: 32,
} as const

function applyImpactFloors(
  computed: ImpactStats | null,
  overrides: { qurans_funded?: number | null; orders_placed?: number | null; countries?: number | null } | null,
): ImpactStats | null {
  if (!computed) return null
  const floor = (n: number, o: number | null | undefined, baseline: number) => {
    const minFloor = typeof o === 'number' && !Number.isNaN(o) && o > baseline ? o : baseline
    return Math.max(n, minFloor)
  }
  return {
    qurans_funded: floor(computed.qurans_funded, overrides?.qurans_funded, IMPACT_BASELINES.qurans_funded),
    orders_placed: floor(computed.orders_placed, overrides?.orders_placed, IMPACT_BASELINES.orders_placed),
    countries: floor(computed.countries, overrides?.countries, IMPACT_BASELINES.countries),
  }
}

export function DashboardPage() {
  const stats = useQuery({
    queryKey: ['dashboard-stats'],
    queryFn: async () => {
      const [content, faq, donations, orders, questions, openOrders, openScholar, impact, overrides] =
        await Promise.all([
          supabase.from('content_items').select('id', { count: 'exact', head: true }),
          supabase.from('faq_items').select('id', { count: 'exact', head: true }),
          supabase.from('donations').select('id', { count: 'exact', head: true }),
          supabase.from('orders').select('id', { count: 'exact', head: true }),
          supabase.from('scholar_questions').select('id', { count: 'exact', head: true }),
          supabase
            .from('orders')
            .select('id', { count: 'exact', head: true })
            .in('status', ['pending', 'paid', 'processing']),
          supabase
            .from('scholar_questions')
            .select('id', { count: 'exact', head: true })
            .in('status', ['submitted', 'in_review']),
          supabase.from('impact_stats').select('*').maybeSingle(),
          supabase.from('app_settings').select('value').eq('key', 'impact_overrides').maybeSingle(),
        ])

      const computed = (impact.data as ImpactStats | null) ?? null
      const ov = (overrides.data?.value ?? null) as {
        qurans_funded?: number | null
        orders_placed?: number | null
        countries?: number | null
      } | null

      return {
        content: content.count ?? 0,
        faq: faq.count ?? 0,
        donations: donations.count ?? 0,
        orders: orders.count ?? 0,
        questions: questions.count ?? 0,
        openOrders: openOrders.count ?? 0,
        openScholar: openScholar.count ?? 0,
        impact: applyImpactFloors(computed, ov),
      }
    },
  })

  const cards: Card[] = stats.data
    ? [
        {
          label: 'Open orders',
          value: stats.data.openOrders,
          to: '/orders',
          search: { status: 'open' },
          hint: 'pending / paid / processing',
        },
        {
          label: 'Open scholar Q&A',
          value: stats.data.openScholar,
          to: '/scholar',
          search: { status: 'open' },
          hint: 'submitted / in_review',
        },
        { label: 'Donations', value: stats.data.donations, to: '/donations' },
        { label: 'All orders', value: stats.data.orders, to: '/orders' },
        { label: 'Scholar questions', value: stats.data.questions, to: '/scholar' },
        { label: 'Content items', value: stats.data.content, to: '/content' },
        { label: 'FAQ entries', value: stats.data.faq, to: '/faq' },
      ]
    : []

  const impact = stats.data?.impact

  return (
    <div>
      <PageHeader
        title="Dashboard"
        description="Ops overview for content and fulfillment. Mobile payments use RevenueCat only — API keys stay in CI/env."
      />

      {impact && (
        <div className="mt-6">
          <h2 className="text-sm font-semibold tracking-wide text-ink-muted uppercase">Impact stats</h2>
          <div className="mt-3 grid gap-4 sm:grid-cols-3">
            <ImpactCard label="Qurans funded" value={impact.qurans_funded} />
            <ImpactCard label="Orders placed" value={impact.orders_placed} />
            <ImpactCard label="Cities / countries" value={impact.countries} />
          </div>
          <p className="mt-2 text-xs text-ink-muted">
            Live totals with optional floors from{' '}
            <Link to="/settings" className="text-accent hover:underline">
              Settings → Impact overrides
            </Link>
            .
          </p>
        </div>
      )}

      <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {stats.isLoading
          ? Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="h-24 animate-pulse rounded-xl bg-cream-dark" />
            ))
          : cards.map((c) => {
              const inner = (
                <>
                  <p className="text-sm text-ink-muted">{c.label}</p>
                  <p className="mt-2 text-3xl font-bold text-ink">{c.value}</p>
                  {c.hint && <p className="mt-1 text-xs text-ink-muted">{c.hint}</p>}
                </>
              )
              if (c.to) {
                return (
                  <Link
                    key={c.label}
                    to={c.to}
                    search={c.search}
                    className="rounded-xl border border-border bg-cream-dark/50 p-5 transition-colors hover:border-accent/40 hover:bg-cream-dark"
                  >
                    {inner}
                  </Link>
                )
              }
              return (
                <div key={c.label} className="rounded-xl border border-border bg-cream-dark/50 p-5">
                  {inner}
                </div>
              )
            })}
      </div>
    </div>
  )
}

function ImpactCard({ label, value }: { label: string; value: number }) {
  return (
    <div className="rounded-xl border border-border bg-surface p-5 shadow-sm">
      <p className="text-sm text-ink-muted">{label}</p>
      <p className="mt-2 text-3xl font-bold text-ink">{value.toLocaleString()}</p>
    </div>
  )
}
