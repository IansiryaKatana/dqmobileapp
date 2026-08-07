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
import { supabase } from '@/lib/supabase'
import type { QuranTopic } from '@/lib/types'
import { toast } from 'sonner'

type Props = {
  open: boolean
  onOpenChange: (open: boolean) => void
  item: QuranTopic | null
}

export function TopicFormSheet({ open, onOpenChange, item }: Props) {
  const queryClient = useQueryClient()
  const isNew = !item
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')
  const [surahs, setSurahs] = useState('')
  const [published, setPublished] = useState(true)
  const [sortOrder, setSortOrder] = useState(0)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (open) {
      setName(item?.name ?? '')
      setDescription(item?.description ?? '')
      setSurahs(item?.surah_numbers?.join(', ') ?? '')
      setPublished(item?.published ?? true)
      setSortOrder(item?.sort_order ?? 0)
    }
  }, [open, item])

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setSaving(true)
    const surah_numbers = surahs
      .split(',')
      .map((s) => parseInt(s.trim(), 10))
      .filter((n) => !Number.isNaN(n))
    const payload = { name, description, surah_numbers, published, sort_order: sortOrder }
    const { error } = isNew
      ? await supabase.from('quran_topics').insert(payload)
      : await supabase.from('quran_topics').update(payload).eq('id', item!.id)
    setSaving(false)
    if (error) {
      toast.error(error.message)
      return
    }
    toast.success(isNew ? 'Topic added' : 'Topic saved')
    await queryClient.invalidateQueries({ queryKey: ['quran-topics'] })
    onOpenChange(false)
  }

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent className="overflow-y-auto">
        <SheetHeader>
          <SheetTitle>{isNew ? 'Add new topic' : 'Edit topic'}</SheetTitle>
          <SheetDescription>Topic chips on the Quran tab in the mobile app.</SheetDescription>
        </SheetHeader>
        <form onSubmit={onSubmit} className="mt-6 flex flex-col gap-5">
          <div className="flex flex-col gap-2">
            <Label htmlFor="topic-name">Name</Label>
            <Input id="topic-name" value={name} onChange={(e) => setName(e.target.value)} required />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="topic-desc">Description</Label>
            <Textarea id="topic-desc" rows={3} value={description} onChange={(e) => setDescription(e.target.value)} />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="topic-surahs">Surah numbers</Label>
            <Input
              id="topic-surahs"
              value={surahs}
              onChange={(e) => setSurahs(e.target.value)}
              placeholder="e.g. 1, 55, 93"
            />
            <p className="text-xs text-ink-subtle">Comma-separated surah numbers</p>
          </div>
          <label className="flex items-center gap-2 text-sm">
            <Checkbox checked={published} onCheckedChange={(v) => setPublished(v === true)} />
            Published
          </label>
          <div className="flex flex-col gap-2">
            <Label htmlFor="topic-sort">Sort order</Label>
            <Input
              id="topic-sort"
              type="number"
              className="w-24"
              value={sortOrder}
              onChange={(e) => setSortOrder(Number(e.target.value))}
            />
          </div>
          <SheetFooter>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>Cancel</Button>
            <Button type="submit" disabled={saving}>{saving ? 'Saving…' : isNew ? 'Add topic' : 'Save changes'}</Button>
          </SheetFooter>
        </form>
      </SheetContent>
    </Sheet>
  )
}
