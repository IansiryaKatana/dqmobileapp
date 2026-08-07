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
import type { FaqItem } from '@/lib/types'
import { toast } from 'sonner'

type Props = {
  open: boolean
  onOpenChange: (open: boolean) => void
  item: FaqItem | null
}

export function FaqFormSheet({ open, onOpenChange, item }: Props) {
  const queryClient = useQueryClient()
  const isNew = !item
  const [question, setQuestion] = useState('')
  const [answer, setAnswer] = useState('')
  const [published, setPublished] = useState(true)
  const [sortOrder, setSortOrder] = useState(0)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (open) {
      setQuestion(item?.question ?? '')
      setAnswer(item?.answer ?? '')
      setPublished(item?.published ?? true)
      setSortOrder(item?.sort_order ?? 0)
    }
  }, [open, item])

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setSaving(true)
    const payload = { question, answer, published, sort_order: sortOrder }
    const { error } = isNew
      ? await supabase.from('faq_items').insert(payload)
      : await supabase.from('faq_items').update(payload).eq('id', item!.id)
    setSaving(false)
    if (error) {
      toast.error(error.message)
      return
    }
    toast.success(isNew ? 'FAQ added' : 'FAQ saved')
    await queryClient.invalidateQueries({ queryKey: ['faq-items'] })
    onOpenChange(false)
  }

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent className="overflow-y-auto">
        <SheetHeader>
          <SheetTitle>{isNew ? 'Add new FAQ' : 'Edit FAQ'}</SheetTitle>
          <SheetDescription>Questions and answers shown in the mobile app FAQ screen.</SheetDescription>
        </SheetHeader>
        <form onSubmit={onSubmit} className="mt-6 flex flex-col gap-5">
          <div className="flex flex-col gap-2">
            <Label htmlFor="faq-q">Question</Label>
            <Input id="faq-q" value={question} onChange={(e) => setQuestion(e.target.value)} required />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="faq-a">Answer</Label>
            <Textarea id="faq-a" rows={5} value={answer} onChange={(e) => setAnswer(e.target.value)} required />
          </div>
          <label className="flex items-center gap-2 text-sm">
            <Checkbox checked={published} onCheckedChange={(v) => setPublished(v === true)} />
            Published
          </label>
          <div className="flex flex-col gap-2">
            <Label htmlFor="faq-sort">Sort order</Label>
            <Input
              id="faq-sort"
              type="number"
              className="w-24"
              value={sortOrder}
              onChange={(e) => setSortOrder(Number(e.target.value))}
            />
          </div>
          <SheetFooter>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>Cancel</Button>
            <Button type="submit" disabled={saving}>{saving ? 'Saving…' : isNew ? 'Add FAQ' : 'Save changes'}</Button>
          </SheetFooter>
        </form>
      </SheetContent>
    </Sheet>
  )
}
