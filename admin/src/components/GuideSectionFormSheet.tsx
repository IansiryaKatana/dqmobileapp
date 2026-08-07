import { FormEvent, useEffect, useState } from 'react'
import { useQueryClient } from '@tanstack/react-query'
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
import { supabase } from '@/lib/supabase'
import type { GuideSection } from '@/lib/types'
import { toast } from 'sonner'

type Props = {
  open: boolean
  onOpenChange: (open: boolean) => void
  section: GuideSection | null
  /** When creating, omit section; mode is create */
  mode?: 'create' | 'edit'
}

const ICONS = [
  'mosque',
  'landscape',
  'volunteer_activism',
  'location_city',
  'luggage',
  'quiz',
  'self_improvement',
  'menu_book',
  'public',
  'water_drop',
  'person',
]

export function GuideSectionFormSheet({ open, onOpenChange, section, mode = 'edit' }: Props) {
  const queryClient = useQueryClient()
  const isCreate = mode === 'create' || !section
  const [slug, setSlug] = useState('')
  const [title, setTitle] = useState('')
  const [subtitle, setSubtitle] = useState('')
  const [badge, setBadge] = useState('')
  const [icon, setIcon] = useState('mosque')
  const [route, setRoute] = useState('')
  const [hubGroup, setHubGroup] = useState<'journey' | 'explore' | 'learn'>('journey')
  const [published, setPublished] = useState(true)
  const [sortOrder, setSortOrder] = useState(0)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (!open) return
    if (section && !isCreate) {
      setSlug(section.slug)
      setTitle(section.title)
      setSubtitle(section.subtitle)
      setBadge(section.badge)
      setIcon(section.icon)
      setRoute(section.route)
      setHubGroup(section.hub_group)
      setPublished(section.published)
      setSortOrder(section.sort_order)
    } else {
      setSlug('')
      setTitle('')
      setSubtitle('')
      setBadge('')
      setIcon('mosque')
      setRoute('/guide/')
      setHubGroup('journey')
      setPublished(true)
      setSortOrder(0)
    }
  }, [open, section, isCreate])

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setSaving(true)
    const payload = {
      title,
      subtitle,
      badge,
      icon,
      route,
      hub_group: hubGroup,
      published,
      sort_order: sortOrder,
      updated_at: new Date().toISOString(),
    }

    if (isCreate) {
      const normalized = slug.trim().toLowerCase().replace(/\s+/g, '-')
      if (!normalized) {
        setSaving(false)
        toast.error('Slug is required')
        return
      }
      const { error } = await supabase.from('guide_sections').insert({
        slug: normalized,
        ...payload,
      })
      setSaving(false)
      if (error) {
        toast.error(error.message)
        return
      }
      toast.success('Guide section created')
      await queryClient.invalidateQueries({ queryKey: ['guide-sections'] })
      onOpenChange(false)
      return
    }

    if (!section) {
      setSaving(false)
      return
    }

    const { error } = await supabase.from('guide_sections').update(payload).eq('slug', section.slug)
    setSaving(false)
    if (error) {
      toast.error(error.message)
      return
    }
    toast.success('Guide section saved')
    await queryClient.invalidateQueries({ queryKey: ['guide-section', section.slug] })
    await queryClient.invalidateQueries({ queryKey: ['guide-sections'] })
    onOpenChange(false)
  }

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent className="overflow-y-auto">
        <SheetHeader>
          <SheetTitle>{isCreate ? 'New guide section' : 'Edit guide section'}</SheetTitle>
          <SheetDescription>
            Hub card fields, route, publish state, and sort order. Use hub group{' '}
            <code>learn</code> for Wudu / How to Pray / New Muslim articles (not shown on the
            Umrah &amp; Hajj hub).
          </SheetDescription>
        </SheetHeader>
        <form onSubmit={onSubmit} className="mt-6 flex flex-col gap-5">
          {isCreate && (
            <div className="flex flex-col gap-2">
              <Label htmlFor="section-slug">Slug</Label>
              <Input
                id="section-slug"
                value={slug}
                onChange={(e) => setSlug(e.target.value)}
                placeholder="umrah"
                required
              />
            </div>
          )}
          <div className="flex flex-col gap-2">
            <Label htmlFor="section-title">Title</Label>
            <Input id="section-title" value={title} onChange={(e) => setTitle(e.target.value)} required />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="section-badge">Badge</Label>
            <Input
              id="section-badge"
              value={badge}
              onChange={(e) => setBadge(e.target.value)}
              placeholder="Step by Step"
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="section-subtitle">Subtitle</Label>
            <Input id="section-subtitle" value={subtitle} onChange={(e) => setSubtitle(e.target.value)} />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="section-icon">Icon</Label>
            <select
              id="section-icon"
              className="flex h-10 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm text-ink"
              value={icon}
              onChange={(e) => setIcon(e.target.value)}
            >
              {ICONS.map((i) => (
                <option key={i} value={i}>
                  {i}
                </option>
              ))}
              {!ICONS.includes(icon) && icon && <option value={icon}>{icon}</option>}
            </select>
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="section-route">Route</Label>
            <Input
              id="section-route"
              value={route}
              onChange={(e) => setRoute(e.target.value)}
              placeholder="/guide/umrah"
              required
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="section-hub">Hub group</Label>
            <select
              id="section-hub"
              className="flex h-10 w-full rounded-lg border border-border bg-surface px-3 py-2 text-sm text-ink"
              value={hubGroup}
              onChange={(e) => setHubGroup(e.target.value as 'journey' | 'explore' | 'learn')}
            >
              <option value="journey">journey</option>
              <option value="explore">explore</option>
              <option value="learn">learn</option>
            </select>
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="section-sort">Sort order</Label>
            <Input
              id="section-sort"
              type="number"
              value={sortOrder}
              onChange={(e) => setSortOrder(Number(e.target.value))}
            />
          </div>
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={published}
              onChange={(e) => setPublished(e.target.checked)}
            />
            Published
          </label>
          <SheetFooter>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Cancel
            </Button>
            <Button type="submit" disabled={saving}>
              {saving ? 'Saving…' : isCreate ? 'Create section' : 'Save changes'}
            </Button>
          </SheetFooter>
        </form>
      </SheetContent>
    </Sheet>
  )
}
