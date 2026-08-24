import { FormEvent, useEffect, useMemo, useRef, useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { ChevronLeft, ImageIcon, Smartphone, Upload, X } from 'lucide-react'
import { toast } from 'sonner'
import { PageHeader } from '@/components/PageHeader'
import { Button } from '@/components/ui/button'
import { Label } from '@/components/ui/label'
import { cn } from '@/lib/utils'
import { supabase } from '@/lib/supabase'
import type { AppPageMedia } from '@/lib/types'

type PhoneScreen = {
  key: string
  title: string
  subtitle: string
  slots: string[]
}

const WUDU_SLOTS = [
  {
    key: 'bismillah',
    label: 'Step 1 · Bismillah',
    description: 'Intention / opening',
    fallback: 'assets/images/wudu_bismillah.png',
  },
  { key: 'hands', label: 'Step 2 · Hands', description: 'Wash both hands', fallback: null },
  { key: 'mouth', label: 'Step 3 · Mouth', description: 'Rinse the mouth', fallback: null },
  { key: 'nose', label: 'Step 4 · Nose', description: 'Rinse the nostrils', fallback: null },
  { key: 'face', label: 'Step 5 · Face', description: 'Wash the full face', fallback: null },
  { key: 'arms', label: 'Step 6 · Arms', description: 'Wash to the elbows', fallback: null },
  { key: 'head', label: 'Step 7 · Head', description: 'Wipe the head', fallback: null },
  { key: 'ears', label: 'Step 8 · Ears', description: 'Wipe both ears', fallback: null },
  { key: 'feet', label: 'Step 9 · Feet', description: 'Wash to the ankles', fallback: null },
  { key: 'closing', label: 'Step 10 · Closing duʿā', description: 'Closing invocation', fallback: null },
] as const

const PRAY_SLOTS = [
  { key: 'intention', label: 'Step 1 · Intention', description: 'Niyyah before starting', fallback: null },
  { key: 'takbir', label: 'Step 2 · Takbir', description: 'Opening Allahu Akbar', fallback: null },
  { key: 'qiyam', label: 'Step 3 · Qiyam', description: 'Standing / recitation', fallback: null },
  { key: 'ruku', label: 'Step 4 · Ruku', description: 'Bowing', fallback: null },
  { key: 'itidal', label: "Step 5 · I'tidal", description: 'Standing after ruku', fallback: null },
  { key: 'sujud', label: 'Step 6 · Sujud', description: 'First prostration', fallback: null },
  { key: 'jalsa', label: 'Step 7 · Jalsa', description: 'Sitting between sujud', fallback: null },
  { key: 'sujud2', label: 'Step 8 · Second sujud', description: 'Complete the rakʿah', fallback: null },
  { key: 'tashahhud', label: 'Step 9 · Tashahhud', description: 'Final sitting', fallback: null },
  { key: 'salam', label: 'Step 10 · Salam', description: 'Ending the prayer', fallback: null },
] as const

const PRAY_SCREENS: PhoneScreen[] = [
  { key: 'pray-fajr', title: 'Fajr prayer', subtitle: 'Step images', slots: PRAY_SLOTS.map((s) => s.key) },
  { key: 'pray-dhuhr', title: 'Dhuhr prayer', subtitle: 'Step images', slots: PRAY_SLOTS.map((s) => s.key) },
  { key: 'pray-asr', title: 'Asr prayer', subtitle: 'Step images', slots: PRAY_SLOTS.map((s) => s.key) },
  { key: 'pray-maghrib', title: 'Maghrib prayer', subtitle: 'Step images', slots: PRAY_SLOTS.map((s) => s.key) },
  { key: 'pray-isha', title: 'Isha prayer', subtitle: 'Step images', slots: PRAY_SLOTS.map((s) => s.key) },
]

const SCREENS: PhoneScreen[] = [
  {
    key: 'onboarding',
    title: 'Onboarding',
    subtitle: 'Background / logo',
    slots: ['background', 'logo'],
  },
  {
    key: 'home',
    title: 'Home',
    subtitle: 'Main tab',
    slots: ['quran_banner', 'app_icon'],
  },
  {
    key: 'order',
    title: 'Order Quran',
    subtitle: 'Product shot',
    slots: ['product'],
  },
  {
    key: 'qibla',
    title: 'Qibla',
    subtitle: 'Compass mark',
    slots: ['compass_mark'],
  },
  {
    key: 'more',
    title: 'More',
    subtitle: 'Menu icons',
    slots: ['kaaba_icon'],
  },
  {
    key: 'pilgrimage',
    title: 'Umrah & Hajj',
    subtitle: 'Featured Kaaba',
    slots: ['featured_kaaba'],
  },
  {
    key: 'logistics',
    title: 'Logistics tips',
    subtitle: 'Guide images',
    slots: ['visa', 'ihram', 'haram', 'nabawi', 'jannat', 'nusuk'],
  },
  {
    key: 'donate',
    title: 'Donate',
    subtitle: 'Optional hero',
    slots: ['hero'],
  },
  {
    key: 'wudu',
    title: 'Wudu Guide',
    subtitle: 'One image per step',
    slots: WUDU_SLOTS.map((s) => s.key),
  },
  ...PRAY_SCREENS,
  {
    key: 'guides',
    title: 'Guides',
    subtitle: 'Wudu illustration',
    slots: ['wudu_hero'],
  },
]

export function AppMediaPage() {
  const queryClient = useQueryClient()
  const [screenKey, setScreenKey] = useState('home')
  const [selectedSlot, setSelectedSlot] = useState<string | null>('quran_banner')
  const [uploading, setUploading] = useState(false)
  const fileRef = useRef<HTMLInputElement>(null)

  const screen = SCREENS.find((s) => s.key === screenKey) ?? SCREENS[1]

  const { data: media = [], isLoading } = useQuery({
    queryKey: ['app-page-media'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('app_page_media')
        .select('*')
        .order('page_key')
        .order('sort_order')
      if (error) throw error
      return data as AppPageMedia[]
    },
  })

  const byPage = useMemo(() => {
    const map = new Map<string, AppPageMedia[]>()
    for (const row of media) {
      const list = map.get(row.page_key) ?? []
      list.push(row)
      map.set(row.page_key, list)
    }
    return map
  }, [media])

  const screenSlots = (byPage.get(screen.key) ?? [])
    .filter((m) => screen.slots.includes(m.slot_key))
    .sort((a, b) => screen.slots.indexOf(a.slot_key) - screen.slots.indexOf(b.slot_key))

  const active =
    screenSlots.find((m) => m.slot_key === selectedSlot) ?? screenSlots[0] ?? null

  useEffect(() => {
    if (isLoading || screenKey !== 'wudu') return
    const existing = new Set((byPage.get('wudu') ?? []).map((m) => m.slot_key))
    const missing = WUDU_SLOTS.filter((s) => !existing.has(s.key))
    if (missing.length === 0) return
    let cancelled = false
    void (async () => {
      const rows = missing.map((s) => ({
        page_key: 'wudu',
        slot_key: s.key,
        label: s.label,
        description: s.description,
        media_type: 'image',
        fallback_asset: s.fallback,
        sort_order: WUDU_SLOTS.findIndex((x) => x.key === s.key) + 1,
      }))
      const { error } = await supabase.from('app_page_media').upsert(rows, {
        onConflict: 'page_key,slot_key',
      })
      if (cancelled) return
      if (error) {
        toast.error(error.message)
        return
      }
      await queryClient.invalidateQueries({ queryKey: ['app-page-media'] })
    })()
    return () => {
      cancelled = true
    }
  }, [isLoading, screenKey, byPage, queryClient])

  useEffect(() => {
    if (isLoading || !screenKey.startsWith('pray-')) return
    const existing = new Set((byPage.get(screenKey) ?? []).map((m) => m.slot_key))
    const missing = PRAY_SLOTS.filter((s) => !existing.has(s.key))
    if (missing.length === 0) return
    let cancelled = false
    void (async () => {
      const rows = missing.map((s) => ({
        page_key: screenKey,
        slot_key: s.key,
        label: s.label,
        description: s.description,
        media_type: 'image',
        fallback_asset: s.fallback,
        sort_order: PRAY_SLOTS.findIndex((x) => x.key === s.key) + 1,
      }))
      const { error } = await supabase.from('app_page_media').upsert(rows, {
        onConflict: 'page_key,slot_key',
      })
      if (cancelled) return
      if (error) {
        toast.error(error.message)
        return
      }
      await queryClient.invalidateQueries({ queryKey: ['app-page-media'] })
    })()
    return () => {
      cancelled = true
    }
  }, [isLoading, screenKey, byPage, queryClient])

  const saveUrl = useMutation({
    mutationFn: async ({ id, url }: { id: string; url: string | null }) => {
      const { error } = await supabase
        .from('app_page_media')
        .update({ url, updated_at: new Date().toISOString() })
        .eq('id', id)
      if (error) throw error
    },
    onSuccess: async () => {
      toast.success('Media updated')
      await queryClient.invalidateQueries({ queryKey: ['app-page-media'] })
    },
    onError: (e: Error) => toast.error(e.message),
  })

  async function onUpload(file: File) {
    if (!active) return
    setUploading(true)
    const path = `app-media/${active.page_key}/${active.slot_key}-${Date.now()}-${file.name}`
    const { error } = await supabase.storage.from('cms-media').upload(path, file, { upsert: true })
    if (error) {
      setUploading(false)
      toast.error(error.message)
      return
    }
    const { data } = supabase.storage.from('cms-media').getPublicUrl(path)
    await saveUrl.mutateAsync({ id: active.id, url: data.publicUrl })
    setUploading(false)
  }

  function goScreen(key: string) {
    setScreenKey(key)
    const next = SCREENS.find((s) => s.key === key)
    setSelectedSlot(next?.slots[0] ?? null)
  }

  return (
    <div className="flex flex-col gap-6">
      <PageHeader
        title="App media"
        description="Navigate a phone preview like the mobile app and replace icons or images. Seeded slots fall back to bundled assets until you upload."
      />

      <div className="grid gap-6 xl:grid-cols-[280px_minmax(0,1fr)_320px]">
        {/* Screen list */}
        <div className="flex flex-col gap-2 rounded-2xl border border-border bg-surface p-3">
          <p className="px-2 text-xs font-semibold uppercase tracking-wide text-ink-subtle">App screens</p>
          {SCREENS.map((s) => {
            const count = byPage.get(s.key)?.filter((m) => m.url).length ?? 0
            const total = byPage.get(s.key)?.length ?? s.slots.length
            return (
              <button
                key={s.key}
                type="button"
                onClick={() => goScreen(s.key)}
                className={cn(
                  'flex items-center justify-between rounded-xl px-3 py-2.5 text-left text-sm transition-colors',
                  screenKey === s.key ? 'bg-accent/15 text-ink font-medium' : 'text-ink-muted hover:bg-cream-dark',
                )}
              >
                <span>
                  <span className="block">{s.title}</span>
                  <span className="text-xs text-ink-subtle">{s.subtitle}</span>
                </span>
                <span className="text-[11px] text-ink-subtle">
                  {count}/{total}
                </span>
              </button>
            )
          })}
        </div>

        {/* Phone frame */}
        <div className="flex flex-col items-center gap-4">
          <div className="relative w-[min(100%,320px)] rounded-[2.25rem] border-[10px] border-stone-800 bg-cream shadow-2xl">
            <div className="absolute left-1/2 top-2 z-10 h-5 w-24 -translate-x-1/2 rounded-full bg-stone-800" />
            <div className="flex h-[560px] flex-col overflow-hidden rounded-[1.6rem] bg-cream pt-8">
              <div className="flex items-center gap-2 border-b border-border px-3 pb-2">
                <button
                  type="button"
                  className="rounded-lg p-1.5 text-ink-muted hover:bg-cream-dark"
                  onClick={() => {
                    const idx = SCREENS.findIndex((s) => s.key === screenKey)
                    if (idx > 0) goScreen(SCREENS[idx - 1].key)
                  }}
                  aria-label="Previous screen"
                >
                  <ChevronLeft className="size-4" />
                </button>
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-bold text-ink">{screen.title}</p>
                  <p className="truncate text-[11px] text-ink-subtle">Tap a slot to replace media</p>
                </div>
                <Smartphone className="size-4 text-ink-subtle" />
              </div>

              <div className="flex-1 overflow-y-auto p-3">
                {isLoading ? (
                  <p className="text-sm text-ink-muted">Loading media…</p>
                ) : screenSlots.length === 0 ? (
                  <div className="flex h-full flex-col items-center justify-center gap-2 text-center text-sm text-ink-muted">
                    <ImageIcon className="size-8 opacity-40" />
                    <p>Run the app_page_media migration to seed slots for this screen.</p>
                  </div>
                ) : (
                  <PhoneScreenPreview
                    screenKey={screen.key}
                    slots={screenSlots}
                    selected={active?.slot_key ?? null}
                    onSelect={setSelectedSlot}
                  />
                )}
              </div>

              <div className="flex justify-around border-t border-border bg-surface px-2 py-2 text-[10px] text-ink-subtle">
                {['Home', 'Quran', 'Donate', 'Qibla', 'More'].map((t) => (
                  <button
                    key={t}
                    type="button"
                    className={cn(
                      'rounded-md px-2 py-1',
                      (t === 'Home' && screenKey === 'home') ||
                        (t === 'Qibla' && screenKey === 'qibla') ||
                        (t === 'More' && (screenKey === 'more' || screenKey === 'pilgrimage')) ||
                        (t === 'Donate' && screenKey === 'donate')
                        ? 'bg-accent/20 font-semibold text-ink'
                        : '',
                    )}
                    onClick={() => {
                      if (t === 'Home') goScreen('home')
                      if (t === 'Qibla') goScreen('qibla')
                      if (t === 'More') goScreen('more')
                      if (t === 'Donate') goScreen('donate')
                    }}
                  >
                    {t}
                  </button>
                ))}
              </div>
            </div>
          </div>
          <p className="max-w-sm text-center text-xs text-ink-subtle">
            Bottom tabs jump between main areas. Use the left list for logistics, onboarding, and guides.
          </p>
        </div>

        {/* Editor */}
        <div className="flex flex-col gap-4 rounded-2xl border border-border bg-surface p-4">
          <p className="text-xs font-semibold uppercase tracking-wide text-ink-subtle">Selected slot</p>
          {active ? (
            <>
              <div>
                <p className="font-medium text-ink">{active.label}</p>
                <p className="text-sm text-ink-muted">{active.description || '—'}</p>
                <p className="mt-1 font-mono text-[11px] text-ink-subtle">
                  {active.page_key}.{active.slot_key}
                </p>
              </div>

              <div className="overflow-hidden rounded-xl border border-border bg-cream-dark">
                {active.url ? (
                  <img src={active.url} alt="" className="h-40 w-full object-contain" />
                ) : (
                  <div className="flex h-40 flex-col items-center justify-center gap-1 px-4 text-center text-xs text-ink-muted">
                    <ImageIcon className="size-7 opacity-40" />
                    <span>Using bundled asset</span>
                    {active.fallback_asset && (
                      <span className="break-all font-mono text-[10px]">{active.fallback_asset}</span>
                    )}
                  </div>
                )}
              </div>

              <input
                ref={fileRef}
                type="file"
                accept="image/*,.svg"
                className="hidden"
                onChange={(e) => {
                  const file = e.target.files?.[0]
                  if (file) void onUpload(file)
                  e.target.value = ''
                }}
              />

              <div className="flex flex-col gap-2">
                <Button type="button" disabled={uploading} onClick={() => fileRef.current?.click()}>
                  <Upload className="size-4" />
                  {uploading ? 'Uploading…' : 'Upload replacement'}
                </Button>
                {active.url && (
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() => saveUrl.mutate({ id: active.id, url: null })}
                  >
                    <X className="size-4" />
                    Clear — use bundled asset
                  </Button>
                )}
              </div>

              <form
                className="flex flex-col gap-2 border-t border-border pt-4"
                onSubmit={(e: FormEvent<HTMLFormElement>) => {
                  e.preventDefault()
                  const fd = new FormData(e.currentTarget)
                  const url = String(fd.get('url') || '').trim()
                  void saveUrl.mutateAsync({ id: active.id, url: url || null })
                }}
              >
                <Label htmlFor="media-url">Or paste image URL</Label>
                <input
                  id="media-url"
                  name="url"
                  defaultValue={active.url ?? ''}
                  key={active.id + (active.url ?? '')}
                  placeholder="https://…"
                  className="flex h-10 w-full rounded-lg border border-border bg-cream px-3 text-sm"
                />
                <Button type="submit" variant="secondary" size="sm">
                  Save URL
                </Button>
              </form>
            </>
          ) : (
            <p className="text-sm text-ink-muted">Select a media slot in the phone preview.</p>
          )}
        </div>
      </div>
    </div>
  )
}

function PhoneScreenPreview({
  screenKey,
  slots,
  selected,
  onSelect,
}: {
  screenKey: string
  slots: AppPageMedia[]
  selected: string | null
  onSelect: (slot: string) => void
}) {
  function SlotCard({ slot }: { slot: AppPageMedia }) {
    const isSel = selected === slot.slot_key
    return (
      <button
        type="button"
        onClick={() => onSelect(slot.slot_key)}
        className={cn(
          'relative overflow-hidden rounded-xl border-2 text-left transition-all',
          isSel ? 'border-accent ring-2 ring-accent/25' : 'border-border hover:border-accent/40',
        )}
      >
        <div className="flex h-28 items-center justify-center bg-cream-dark">
          {slot.url ? (
            <img src={slot.url} alt="" className="h-full w-full object-cover" />
          ) : (
            <div className="flex flex-col items-center gap-1 px-2 text-center">
              <ImageIcon className="size-6 text-ink-subtle" />
              <span className="text-[10px] text-ink-subtle">Bundled</span>
            </div>
          )}
        </div>
        <div className="bg-surface px-2 py-1.5">
          <p className="truncate text-xs font-medium text-ink">{slot.label}</p>
          {slot.url ? (
            <p className="text-[10px] text-emerald-700">Custom upload</p>
          ) : (
            <p className="truncate text-[10px] text-ink-subtle">{slot.fallback_asset ?? 'No default'}</p>
          )}
        </div>
      </button>
    )
  }

  if (screenKey === 'home') {
    const banner = slots.find((s) => s.slot_key === 'quran_banner')
    const icon = slots.find((s) => s.slot_key === 'app_icon')
    return (
      <div className="flex flex-col gap-3">
        <p className="text-sm font-bold text-ink">Home</p>
        {banner && <SlotCard slot={banner} />}
        <div className="grid grid-cols-2 gap-2">{icon && <SlotCard slot={icon} />}</div>
      </div>
    )
  }

  if (screenKey === 'logistics' || screenKey === 'wudu' || screenKey.startsWith('pray-')) {
    return (
      <div className="grid grid-cols-2 gap-2">
        {slots.map((s) => (
          <SlotCard key={s.id} slot={s} />
        ))}
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-3">
      <p className="text-sm font-bold text-ink capitalize">{screenKey.replace('-', ' ')}</p>
      {slots.map((s) => (
        <SlotCard key={s.id} slot={s} />
      ))}
    </div>
  )
}
