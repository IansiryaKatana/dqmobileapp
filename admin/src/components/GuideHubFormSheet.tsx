import { FormEvent, useEffect, useState } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetFooter,
  SheetHeader,
  SheetTitle,
} from '@/components/ui/sheet'
import { supabase } from '@/lib/supabase'
import type { PilgrimageHubSettings } from '@/lib/types'
import { toast } from 'sonner'

type Props = {
  open: boolean
  onOpenChange: (open: boolean) => void
  settings: PilgrimageHubSettings | null
}

export function GuideHubFormSheet({ open, onOpenChange, settings }: Props) {
  const queryClient = useQueryClient()
  const [form, setForm] = useState<PilgrimageHubSettings>({
    eyebrow: '',
    title: '',
    disclaimer: '',
  })
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (open && settings) {
      setForm(settings)
    }
  }, [open, settings])

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setSaving(true)
    const { error } = await supabase.from('app_settings').upsert({
      key: 'pilgrimage_hub',
      value: form,
      description: 'Umrah & Hajj hub hero and disclaimer copy',
      updated_at: new Date().toISOString(),
    })
    setSaving(false)
    if (error) {
      toast.error(error.message)
      return
    }
    toast.success('Hub copy saved')
    await queryClient.invalidateQueries({ queryKey: ['pilgrimage-hub'] })
    onOpenChange(false)
  }

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent className="overflow-y-auto">
        <SheetHeader>
          <SheetTitle>Edit hub screen</SheetTitle>
          <SheetDescription>Hero eyebrow, title, and disclaimer on the Umrah & Hajj hub in the mobile app.</SheetDescription>
        </SheetHeader>
        <form onSubmit={onSubmit} className="mt-6 flex flex-col gap-5">
          <div className="flex flex-col gap-2">
            <Label htmlFor="hub-eyebrow">Eyebrow</Label>
            <Input
              id="hub-eyebrow"
              value={form.eyebrow}
              onChange={(e) => setForm({ ...form, eyebrow: e.target.value })}
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="hub-title">Hero title</Label>
            <Input
              id="hub-title"
              value={form.title}
              onChange={(e) => setForm({ ...form, title: e.target.value })}
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="hub-disclaimer">Disclaimer</Label>
            <Textarea
              id="hub-disclaimer"
              rows={4}
              value={form.disclaimer}
              onChange={(e) => setForm({ ...form, disclaimer: e.target.value })}
            />
          </div>
          <SheetFooter>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Cancel
            </Button>
            <Button type="submit" disabled={saving}>
              {saving ? 'Saving…' : 'Save changes'}
            </Button>
          </SheetFooter>
        </form>
      </SheetContent>
    </Sheet>
  )
}
