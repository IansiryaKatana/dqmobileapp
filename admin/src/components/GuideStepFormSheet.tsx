import { FormEvent, useEffect, useState } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Checkbox } from '@/components/ui/checkbox'
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetFooter,
  SheetHeader,
  SheetTitle,
} from '@/components/ui/sheet'
import { ImageUploadField } from '@/components/ImageUploadField'
import { supabase } from '@/lib/supabase'
import type { GuideStep } from '@/lib/types'
import { toast } from 'sonner'

type Props = {
  open: boolean
  onOpenChange: (open: boolean) => void
  guideSlug: string
  item: GuideStep | null
}

const WUDU_ICONS = [
  { value: 'favorite_border', label: 'Heart (intention)' },
  { value: 'back_hand', label: 'Hands' },
  { value: 'water_drop', label: 'Water drop' },
  { value: 'air', label: 'Air / nose' },
  { value: 'face', label: 'Face' },
  { value: 'pan_tool', label: 'Arms / takbir' },
  { value: 'self_improvement', label: 'Head / ruku' },
  { value: 'hearing', label: 'Ears' },
  { value: 'directions_walk', label: 'Feet' },
  { value: 'check_circle', label: 'Check / closing' },
  { value: 'menu_book', label: 'Book / qiyam' },
  { value: 'accessibility_new', label: "I'tidal" },
  { value: 'expand', label: 'Sujud' },
  { value: 'airline_seat_recline_normal', label: 'Jalsa' },
  { value: 'volunteer_activism', label: 'Tashahhud' },
  { value: 'waving_hand', label: 'Salam' },
]

const PRAY_STEP_SLUGS = new Set(['pray-fajr', 'pray-dhuhr', 'pray-asr', 'pray-maghrib', 'pray-isha'])
const PILGRIMAGE_SLUGS = new Set(['umrah', 'hajj'])

function parseLegacyBody(body: string): Partial<GuideStep> {
  const trimmed = body.trim()
  if (!trimmed.startsWith('{')) return { description: body }
  try {
    const meta = JSON.parse(trimmed) as Record<string, unknown>
    return {
      subtitle: typeof meta.subtitle === 'string' ? meta.subtitle : '',
      description: typeof meta.desc === 'string' ? meta.desc : '',
      arabic: typeof meta.arabic === 'string' ? meta.arabic : '',
      arabic_en: typeof meta.arabic_en === 'string' ? meta.arabic_en : '',
      icon: typeof meta.icon === 'string' ? meta.icon : '',
      icon_url: typeof meta.icon_url === 'string' ? meta.icon_url : null,
      repeat_label: typeof meta.repeat === 'string' ? meta.repeat : '',
      time_label: typeof meta.time === 'string' ? meta.time : '',
      rakaat: typeof meta.rakaat === 'number' ? meta.rakaat : Number(meta.rakaat) || null,
      accent: typeof meta.accent === 'string' ? meta.accent : '',
    }
  } catch {
    return { description: body }
  }
}

export function GuideStepFormSheet({ open, onOpenChange, guideSlug, item }: Props) {
  const queryClient = useQueryClient()
  const isNew = !item
  const isWudu = guideSlug === 'wudu'
  const isPraySteps = PRAY_STEP_SLUGS.has(guideSlug)
  const isPilgrimage = PILGRIMAGE_SLUGS.has(guideSlug)
  const isInstructional = isWudu || isPraySteps || isPilgrimage
  const isPray = guideSlug === 'how-to-pray'
  const isRich = isInstructional || isPray

  const [title, setTitle] = useState('')
  const [subtitle, setSubtitle] = useState('')
  const [description, setDescription] = useState('')
  const [arabic, setArabic] = useState('')
  const [arabicEn, setArabicEn] = useState('')
  const [icon, setIcon] = useState(isInstructional ? 'favorite_border' : '')
  const [iconUrl, setIconUrl] = useState<string | null>(null)
  const [repeatLabel, setRepeatLabel] = useState('')
  const [timeLabel, setTimeLabel] = useState('')
  const [rakaat, setRakaat] = useState(2)
  const [accent, setAccent] = useState('#0B1F3A')
  const [body, setBody] = useState('')
  const [published, setPublished] = useState(true)
  const [sortOrder, setSortOrder] = useState(1)
  const [saving, setSaving] = useState(false)
  const [uploading, setUploading] = useState(false)

  useEffect(() => {
    if (!open) return
    const legacy = item ? parseLegacyBody(item.body ?? '') : {}
    setTitle(item?.title ?? '')
    setSubtitle(item?.subtitle || legacy.subtitle || '')
    setDescription(item?.description || legacy.description || '')
    setArabic(item?.arabic || legacy.arabic || '')
    setArabicEn(item?.arabic_en || legacy.arabic_en || '')
    setIcon(item?.icon || legacy.icon || (isInstructional ? 'favorite_border' : ''))
    setIconUrl(item?.icon_url || legacy.icon_url || null)
    setRepeatLabel(item?.repeat_label || legacy.repeat_label || '')
    setTimeLabel(item?.time_label || legacy.time_label || '')
    setRakaat(item?.rakaat ?? legacy.rakaat ?? 2)
    setAccent(item?.accent || legacy.accent || '#0B1F3A')
    setBody(!isRich ? (item?.body ?? '') : '')
    setPublished(item?.published ?? true)
    setSortOrder(item?.sort_order ?? 1)
  }, [open, item, isRich, isInstructional])

  async function uploadIcon(file: File) {
    setUploading(true)
    const path = `guide-icons/${Date.now()}-${file.name}`
    const { error } = await supabase.storage.from('cms-media').upload(path, file, { upsert: true })
    setUploading(false)
    if (error) {
      toast.error(error.message)
      return
    }
    const { data } = supabase.storage.from('cms-media').getPublicUrl(path)
    setIconUrl(data.publicUrl)
  }

  function buildBody(): string {
    if (!isRich) return body
    if (isPray) {
      return JSON.stringify({
        arabic: arabic || undefined,
        time: timeLabel || undefined,
        rakaat,
        accent: accent || undefined,
      })
    }
    return JSON.stringify({
      subtitle: subtitle || undefined,
      desc: description || undefined,
      arabic: arabic || undefined,
      arabic_en: arabicEn || undefined,
      icon: icon || undefined,
      icon_url: iconUrl || undefined,
      repeat: repeatLabel || undefined,
    })
  }

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setSaving(true)
    const composedBody = buildBody()
    const base = {
      guide_slug: guideSlug,
      title,
      body: composedBody,
      published,
      sort_order: sortOrder,
      updated_at: new Date().toISOString(),
    }
    const rich = {
      ...base,
      subtitle: isInstructional ? subtitle : '',
      description: isInstructional ? description : isPray ? '' : description || body,
      arabic: arabic || null,
      arabic_en: isInstructional ? arabicEn || null : null,
      icon: isInstructional ? icon : '',
      icon_url: isInstructional ? iconUrl : null,
      repeat_label: isInstructional ? repeatLabel || null : null,
      time_label: isPray ? timeLabel || null : null,
      rakaat: isPray ? rakaat : null,
      accent: isPray ? accent || null : null,
    }

    let error = (
      isNew
        ? await supabase.from('guide_steps').insert(rich)
        : await supabase.from('guide_steps').update(rich).eq('id', item!.id)
    ).error

    // Columns may not exist until migration is applied — fall back to body JSON.
    if (error && /column|schema cache/i.test(error.message)) {
      error = (
        isNew
          ? await supabase.from('guide_steps').insert(base)
          : await supabase.from('guide_steps').update(base).eq('id', item!.id)
      ).error
    }

    setSaving(false)
    if (error) {
      toast.error(error.message)
      return
    }
    toast.success(isNew ? 'Step added' : 'Step saved')
    await queryClient.invalidateQueries({ queryKey: ['guide-steps', guideSlug] })
    onOpenChange(false)
  }

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent className="overflow-y-auto">
        <SheetHeader>
          <SheetTitle>{isNew ? 'Add guide step' : 'Edit guide step'}</SheetTitle>
          <SheetDescription>
            {isInstructional
              ? 'Instructional step fields map 1:1 to the mobile guide. Sort order is the step number in the app. Prefer App Media for step images.'
              : isPray
                ? 'Prayer card fields for the How to Pray screen. Sort order controls list order.'
                : 'Shown in order on the mobile guide screen.'}
          </SheetDescription>
        </SheetHeader>
        <form onSubmit={onSubmit} className="mt-6 flex flex-col gap-5">
          <div className="flex flex-col gap-2">
            <Label htmlFor="step-title">Step title</Label>
            <Input
              id="step-title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder={isInstructional ? 'Intention' : 'Step title'}
              required
            />
          </div>

          {isInstructional && (
            <>
              <div className="flex flex-col gap-2">
                <Label htmlFor="step-subtitle">Subtitle</Label>
                <Input
                  id="step-subtitle"
                  value={subtitle}
                  onChange={(e) => setSubtitle(e.target.value)}
                  placeholder="Niyyah"
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="step-desc">Description</Label>
                <Textarea
                  id="step-desc"
                  rows={isPilgrimage ? 10 : 3}
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  placeholder={
                    isPilgrimage
                      ? 'Markdown: paragraphs, lists, **Men** / **Women**, and > blockquotes for du’as'
                      : 'Stand facing the Qibla…'
                  }
                  required
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="step-arabic">{isPilgrimage ? 'Ritual Arabic name' : 'Arabic text'}</Label>
                <Textarea
                  id="step-arabic"
                  rows={2}
                  dir="rtl"
                  className="text-lg"
                  value={arabic}
                  onChange={(e) => setArabic(e.target.value)}
                  placeholder="ٱللَّهُ أَكْبَرُ"
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="step-arabic-en">Arabic transliteration / meaning</Label>
                <Textarea
                  id="step-arabic-en"
                  rows={2}
                  value={arabicEn}
                  onChange={(e) => setArabicEn(e.target.value)}
                  placeholder="Allahu Akbar — Allah is the Greatest"
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="step-repeat">Repeat label</Label>
                <Input
                  id="step-repeat"
                  value={repeatLabel}
                  onChange={(e) => setRepeatLabel(e.target.value)}
                  placeholder="× 3 times"
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="step-icon">Icon key</Label>
                <select
                  id="step-icon"
                  value={icon}
                  onChange={(e) => setIcon(e.target.value)}
                  className="flex h-10 w-full rounded-lg border border-border bg-surface px-3 text-sm"
                >
                  {WUDU_ICONS.map((opt) => (
                    <option key={opt.value} value={opt.value}>
                      {opt.label}
                    </option>
                  ))}
                </select>
                <p className="text-xs text-ink-subtle">Built-in Material icon. Upload step images in App Media for best results.</p>
              </div>
              <ImageUploadField
                label="Custom icon (optional)"
                value={iconUrl}
                onChange={setIconUrl}
                onUpload={uploadIcon}
                uploading={uploading}
              />
            </>
          )}

          {isPray && (
            <>
              <div className="flex flex-col gap-2">
                <Label htmlFor="pray-arabic">Arabic name</Label>
                <Input id="pray-arabic" dir="rtl" value={arabic} onChange={(e) => setArabic(e.target.value)} />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="pray-time">Time label</Label>
                <Input id="pray-time" value={timeLabel} onChange={(e) => setTimeLabel(e.target.value)} placeholder="Before sunrise" />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div className="flex flex-col gap-2">
                  <Label htmlFor="pray-rakaat">Rakaat</Label>
                  <Input
                    id="pray-rakaat"
                    type="number"
                    min={1}
                    value={rakaat}
                    onChange={(e) => setRakaat(Number(e.target.value))}
                  />
                </div>
                <div className="flex flex-col gap-2">
                  <Label htmlFor="pray-accent">Accent color</Label>
                  <Input id="pray-accent" value={accent} onChange={(e) => setAccent(e.target.value)} placeholder="#FF8C42" />
                </div>
              </div>
            </>
          )}

          {!isRich && (
            <div className="flex flex-col gap-2">
              <Label htmlFor="step-body">Body</Label>
              <Textarea id="step-body" rows={8} value={body} onChange={(e) => setBody(e.target.value)} required />
            </div>
          )}

          <label className="flex items-center gap-2 text-sm">
            <Checkbox checked={published} onCheckedChange={(v) => setPublished(v === true)} />
            Published
          </label>
          <div className="flex flex-col gap-2">
            <Label htmlFor="step-sort">Sort order (step number in app)</Label>
            <Input
              id="step-sort"
              type="number"
              className="w-24"
              value={sortOrder}
              onChange={(e) => setSortOrder(Number(e.target.value))}
              required
            />
            <p className="text-xs text-ink-subtle">1 = first step. The mobile app shows this as “Step {sortOrder || 1}”.</p>
          </div>
          <SheetFooter>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Cancel
            </Button>
            <Button type="submit" disabled={saving}>
              {saving ? 'Saving…' : isNew ? 'Add step' : 'Save changes'}
            </Button>
          </SheetFooter>
        </form>
      </SheetContent>
    </Sheet>
  )
}
