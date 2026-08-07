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
import { broadcastPush, pushResultToastMessage } from '@/lib/push'
import { CONTENT_KIND_META, type ContentKind } from '@/lib/content'
import type { ContentItem } from '@/lib/types'
import { toast } from 'sonner'

type Props = {
  open: boolean
  onOpenChange: (open: boolean) => void
  item: ContentItem | null
  kind: ContentKind
  onSaved?: () => void
}

const emptyForm = (kind: ContentKind): Partial<ContentItem> => ({
  title: '',
  slug: '',
  summary: '',
  body: '',
  topic: 'General',
  kind,
  image_url: null,
  published: false,
  sort_order: 0,
})

export function ContentFormSheet({ open, onOpenChange, item, kind, onSaved }: Props) {
  const queryClient = useQueryClient()
  const meta = CONTENT_KIND_META[kind]
  const isNew = !item
  const [form, setForm] = useState<Partial<ContentItem>>(emptyForm(kind))
  const [saving, setSaving] = useState(false)
  const [uploading, setUploading] = useState(false)
  const [notifyUsers, setNotifyUsers] = useState(false)

  useEffect(() => {
    if (open) {
      setForm(item ?? emptyForm(kind))
      // Default on when publishing a new campaign, or flipping an existing one to published.
      setNotifyUsers(kind === 'campaign' && !(item?.published))
    }
  }, [open, item, kind])

  async function uploadImage(file: File) {
    setUploading(true)
    const path = `${Date.now()}-${file.name}`
    const { error } = await supabase.storage.from('cms-media').upload(path, file, { upsert: true })
    setUploading(false)
    if (error) {
      toast.error(error.message)
      return
    }
    const { data } = supabase.storage.from('cms-media').getPublicUrl(path)
    setForm((f) => ({ ...f, image_url: data.publicUrl }))
  }

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setSaving(true)
    const willPublish = form.published === true
    const payload = {
      slug: form.slug || `draft-${Date.now()}`,
      title: form.title || `Untitled ${meta.label}`,
      summary: form.summary ?? '',
      body: form.body ?? '',
      topic: form.topic ?? 'General',
      kind,
      image_url: form.image_url ?? null,
      published: willPublish,
      sort_order: form.sort_order ?? 0,
      updated_at: new Date().toISOString(),
    }

    const { error } = isNew
      ? await supabase.from('content_items').insert(payload)
      : await supabase.from('content_items').update(payload).eq('id', item!.id)

    if (error) {
      setSaving(false)
      toast.error(error.message)
      return
    }

    const shouldNotify = kind === 'campaign' && notifyUsers && willPublish

    if (shouldNotify) {
      const result = await broadcastPush({
        title: payload.title,
        body: payload.summary || `New campaign: ${payload.title}`,
        deepLink: '/donate',
      })
      const msg = pushResultToastMessage(result)
      if (msg.ok) toast.success(`${meta.label} published — ${msg.text}`)
      else toast.warning(`${meta.label} saved, but push failed: ${msg.text}`)
    } else {
      toast.success(isNew ? `${meta.label} created` : `${meta.label} saved`)
    }

    setSaving(false)
    await queryClient.invalidateQueries({ queryKey: ['content-items'] })
    onOpenChange(false)
    onSaved?.()
  }

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent className="overflow-y-auto">
        <SheetHeader>
          <SheetTitle>{isNew ? meta.addLabel : `Edit ${meta.label.toLowerCase()}`}</SheetTitle>
          <SheetDescription>{meta.description}</SheetDescription>
        </SheetHeader>
        <form onSubmit={onSubmit} className="mt-6 flex flex-col gap-5">
          <div className="flex flex-col gap-2">
            <Label htmlFor="title">Title</Label>
            <Input
              id="title"
              value={form.title ?? ''}
              onChange={(e) => setForm({ ...form, title: e.target.value })}
              placeholder={`${meta.label} title`}
              required
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="slug">Slug</Label>
            <Input
              id="slug"
              value={form.slug ?? ''}
              onChange={(e) => setForm({ ...form, slug: e.target.value })}
              placeholder="url-friendly-slug"
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="topic">Topic</Label>
            <Input
              id="topic"
              value={form.topic ?? ''}
              onChange={(e) => setForm({ ...form, topic: e.target.value })}
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="summary">Summary</Label>
            <Textarea
              id="summary"
              rows={2}
              value={form.summary ?? ''}
              onChange={(e) => setForm({ ...form, summary: e.target.value })}
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="body">Body</Label>
            <Textarea
              id="body"
              rows={10}
              value={form.body ?? ''}
              onChange={(e) => setForm({ ...form, body: e.target.value })}
              className="font-mono text-xs"
            />
          </div>
          <ImageUploadField
            value={form.image_url}
            onChange={(url) => setForm({ ...form, image_url: url })}
            onUpload={uploadImage}
            uploading={uploading}
          />
          <div className="flex flex-wrap items-center gap-6">
            <label className="flex items-center gap-2 text-sm">
              <Checkbox
                checked={form.published ?? false}
                onCheckedChange={(checked) => setForm({ ...form, published: checked === true })}
              />
              Published
            </label>
            {kind === 'campaign' && (
              <label className="flex items-center gap-2 text-sm">
                <Checkbox
                  checked={notifyUsers}
                  onCheckedChange={(checked) => setNotifyUsers(checked === true)}
                  disabled={!form.published}
                />
                Notify app users (push)
              </label>
            )}
            <div className="flex items-center gap-2">
              <Label htmlFor="sort">Sort order</Label>
              <Input
                id="sort"
                type="number"
                className="w-24"
                value={form.sort_order ?? 0}
                onChange={(e) => setForm({ ...form, sort_order: Number(e.target.value) })}
              />
            </div>
          </div>
          {kind === 'campaign' && notifyUsers && form.published && (
            <p className="text-xs text-ink-subtle">
              Sends a push with this title + summary to devices that allowed notifications. Requires FCM
              secret on <code>push-broadcast</code> (Notifications page).
            </p>
          )}
          <SheetFooter>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Cancel
            </Button>
            <Button type="submit" disabled={saving}>
              {saving ? 'Saving…' : isNew ? meta.addLabel : 'Save changes'}
            </Button>
          </SheetFooter>
        </form>
      </SheetContent>
    </Sheet>
  )
}
