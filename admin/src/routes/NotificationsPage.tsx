import { FormEvent, useEffect, useMemo, useState } from 'react'
import { Link } from '@tanstack/react-router'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import type { ColumnDef } from '@tanstack/react-table'
import { CircleHelp, Pencil, Plus, Trash2 } from 'lucide-react'
import { toast } from 'sonner'
import { DataTable } from '@/components/DataTable'
import { PageHeader } from '@/components/PageHeader'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Dialog,
  DialogBody,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
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
import { Textarea } from '@/components/ui/textarea'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import { broadcastPush, pushResultToastMessage } from '@/lib/push'
import { supabase } from '@/lib/supabase'
import type { PushBroadcast, PushDefaultsSettings } from '@/lib/types'

function formatWhen(iso: string | null) {
  if (!iso) return '—'
  try {
    return new Date(iso).toLocaleString()
  } catch {
    return iso
  }
}

function statusBadge(status: PushBroadcast['status']) {
  if (status === 'sent') return <Badge variant="success">Sent</Badge>
  if (status === 'failed') return <Badge variant="destructive">Failed</Badge>
  return <Badge variant="draft">Draft</Badge>
}

export function NotificationsPage() {
  const queryClient = useQueryClient()
  const [helpOpen, setHelpOpen] = useState(false)
  const [sheetOpen, setSheetOpen] = useState(false)
  const [editing, setEditing] = useState<PushBroadcast | null>(null)
  const [deleteId, setDeleteId] = useState<string | null>(null)

  const { data: rows = [], isLoading, error: loadError } = useQuery({
    queryKey: ['push-broadcasts'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('push_broadcasts')
        .select('*')
        .order('created_at', { ascending: false })
      if (error) throw error
      return data as PushBroadcast[]
    },
  })

  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('push_broadcasts').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: async () => {
      toast.success('Broadcast deleted')
      setDeleteId(null)
      await queryClient.invalidateQueries({ queryKey: ['push-broadcasts'] })
    },
    onError: (e: Error) => toast.error(e.message),
  })

  const columns: ColumnDef<PushBroadcast>[] = useMemo(
    () => [
      {
        header: 'Title',
        accessorKey: 'title',
        cell: ({ row }) => (
          <div className="min-w-0 max-w-[220px]">
            <p className="truncate font-medium text-ink">{row.original.title}</p>
            <p className="truncate text-xs text-ink-muted">{row.original.body}</p>
          </div>
        ),
      },
      {
        id: 'status',
        header: 'Status',
        cell: ({ row }) => statusBadge(row.original.status),
      },
      {
        id: 'delivery',
        header: 'Delivery',
        cell: ({ row }) => {
          const r = row.original
          if (r.status === 'draft') return <span className="text-ink-muted">—</span>
          return (
            <span className="text-sm text-ink-muted">
              {r.sent_count}/{r.recipients}
              {r.failed_count ? ` · ${r.failed_count} fail` : ''}
            </span>
          )
        },
      },
      {
        id: 'link',
        header: 'Deep link',
        cell: ({ row }) => (
          <code className="text-xs text-ink-muted">{row.original.deep_link || '/'}</code>
        ),
      },
      {
        id: 'when',
        header: 'Updated',
        cell: ({ row }) => (
          <span className="whitespace-nowrap text-xs text-ink-muted">
            {formatWhen(row.original.sent_at ?? row.original.updated_at)}
          </span>
        ),
      },
      {
        id: 'actions',
        header: 'Actions',
        cell: ({ row }) => (
          <div className="flex flex-wrap gap-1">
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={() => {
                setEditing(row.original)
                setSheetOpen(true)
              }}
            >
              <Pencil className="size-3.5" />
              <span className="hidden sm:inline">Edit</span>
            </Button>
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={() => setDeleteId(row.original.id)}
            >
              <Trash2 className="size-3.5" />
              <span className="hidden sm:inline">Delete</span>
            </Button>
          </div>
        ),
      },
    ],
    [],
  )

  return (
    <div className="flex flex-col gap-6">
      <PageHeader
        title="Push notifications"
        description="Compose and manage broadcasts. Campaigns can also notify on publish."
      >
        <Button type="button" variant="outline" onClick={() => setHelpOpen(true)}>
          <CircleHelp className="size-4" />
          Help
        </Button>
        <Button
          type="button"
          onClick={() => {
            setEditing(null)
            setSheetOpen(true)
          }}
        >
          <Plus className="size-4" />
          New broadcast
        </Button>
      </PageHeader>

      {loadError ? (
        <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
          <p className="font-medium">Could not load broadcasts</p>
          <p className="mt-1 text-xs">
            {(loadError as Error).message?.includes('404') ||
            (loadError as Error).message?.includes('PGRST') ||
            (loadError as Error).message?.includes('does not exist')
              ? 'Run migration 20260805200000_push_broadcasts.sql in the Supabase SQL Editor, then refresh.'
              : (loadError as Error).message}
          </p>
        </div>
      ) : isLoading ? (
        <p className="text-sm text-ink-muted">Loading broadcasts…</p>
      ) : (
        <DataTable
          data={rows}
          columns={columns}
          rowId={(row) => row.id}
          emptyMessage="No broadcasts yet. Create one to notify app users."
        />
      )}

      <BroadcastFormSheet
        open={sheetOpen}
        onOpenChange={setSheetOpen}
        item={editing}
        onSaved={() => queryClient.invalidateQueries({ queryKey: ['push-broadcasts'] })}
      />

      <FcmHelpDialog open={helpOpen} onOpenChange={setHelpOpen} />

      <AlertDialog open={!!deleteId} onOpenChange={(o) => !o && setDeleteId(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete broadcast?</AlertDialogTitle>
            <AlertDialogDescription>
              This removes the history row. It does not retract notifications already delivered.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel />
            <AlertDialogAction
              onClick={() => deleteId && deleteMutation.mutate(deleteId)}
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}

function FcmHelpDialog({
  open,
  onOpenChange,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
}) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>FCM setup help</DialogTitle>
          <DialogDescription>
            Without the edge-function secret, broadcasts save but cannot deliver pushes.
          </DialogDescription>
        </DialogHeader>
        <DialogBody className="space-y-3 text-sm text-ink-muted">
          <ol className="list-decimal space-y-2 pl-5">
            <li>
              Open{' '}
              <a
                className="font-medium text-accent hover:underline"
                href="https://console.firebase.google.com/project/awesome-62ce1/settings/serviceaccounts/adminsdk"
                target="_blank"
                rel="noreferrer"
              >
                Firebase → Service accounts
              </a>{' '}
              (project <code>awesome-62ce1</code>).
            </li>
            <li>Generate a new private key → download the JSON.</li>
            <li>
              Supabase → Edge Functions → Secrets → add{' '}
              <code>FCM_SERVICE_ACCOUNT_JSON</code> (entire JSON, one line).
            </li>
            <li>
              Deploy:{' '}
              <code className="text-xs">
                supabase functions deploy push-broadcast --project-ref mildsuuygbzgdunwmzuk
              </code>
            </li>
            <li>On a phone: allow notifications while signed in so <code>device_tokens</code> fills.</li>
          </ol>
          <p className="text-xs">
            One-offs can also go through Firebase Console → Messaging. Campaign “Notify app users”
            uses the same edge function.
          </p>
          <div className="flex flex-wrap gap-3 text-sm font-medium">
            <Link to="/content" className="text-accent hover:underline" onClick={() => onOpenChange(false)}>
              Content → Campaigns
            </Link>
            <Link to="/settings" className="text-accent hover:underline" onClick={() => onOpenChange(false)}>
              Home campaign
            </Link>
          </div>
        </DialogBody>
        <DialogFooter>
          <Button type="button" onClick={() => onOpenChange(false)}>
            Got it
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}

function BroadcastFormSheet({
  open,
  onOpenChange,
  item,
  onSaved,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  item: PushBroadcast | null
  onSaved: () => void
}) {
  const isNew = !item
  const [title, setTitle] = useState('')
  const [body, setBody] = useState('')
  const [deepLink, setDeepLink] = useState('/')
  const [saving, setSaving] = useState(false)

  const { data: defaults } = useQuery({
    queryKey: ['push-defaults'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('app_settings')
        .select('value')
        .eq('key', 'push_defaults')
        .maybeSingle()
      if (error) throw error
      return (data?.value ?? {}) as PushDefaultsSettings
    },
  })

  useEffect(() => {
    if (!open) return
    if (item) {
      setTitle(item.title)
      setBody(item.body)
      setDeepLink(item.deep_link || '/')
    } else {
      setTitle('')
      setBody('')
      setDeepLink(defaults?.default_deep_link || '/donate')
    }
  }, [open, item, defaults?.default_deep_link])

  async function saveRow(status: 'draft' | 'sent' | 'failed', extra: Partial<PushBroadcast> = {}) {
    const { data: userData } = await supabase.auth.getUser()
    const payload = {
      title: title.trim(),
      body: body.trim(),
      deep_link: deepLink.trim() || '/',
      status,
      updated_at: new Date().toISOString(),
      created_by: userData.user?.id ?? null,
      ...extra,
    }
    if (isNew) {
      const { data, error } = await supabase.from('push_broadcasts').insert(payload).select('*').single()
      if (error) throw error
      return data as PushBroadcast
    }
    const { data, error } = await supabase
      .from('push_broadcasts')
      .update(payload)
      .eq('id', item!.id)
      .select('*')
      .single()
    if (error) throw error
    return data as PushBroadcast
  }

  async function onSaveDraft(e: FormEvent) {
    e.preventDefault()
    if (!title.trim() || !body.trim()) {
      toast.error('Title and body are required')
      return
    }
    setSaving(true)
    try {
      await saveRow('draft')
      toast.success(isNew ? 'Draft saved' : 'Broadcast updated')
      onSaved()
      onOpenChange(false)
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Save failed')
    } finally {
      setSaving(false)
    }
  }

  async function onSend() {
    if (!title.trim() || !body.trim()) {
      toast.error('Title and body are required')
      return
    }
    setSaving(true)
    try {
      const row = await saveRow(item?.status === 'sent' ? item.status : 'draft')
      const result = await broadcastPush({
        title: row.title,
        body: row.body,
        deepLink: row.deep_link,
        broadcastId: row.id,
      })
      const msg = pushResultToastMessage(result)
      if (!msg.ok) {
        await supabase
          .from('push_broadcasts')
          .update({
            status: 'failed',
            error_message: result.message ?? msg.text,
            updated_at: new Date().toISOString(),
          })
          .eq('id', row.id)
        toast.error(msg.text)
      } else {
        // Edge function updates counts when configured; refresh local status if needed
        if (result.configured !== false) {
          await supabase
            .from('push_broadcasts')
            .update({
              status: (result.sent ?? 0) > 0 || result.ok ? 'sent' : 'failed',
              sent_count: result.sent ?? 0,
              failed_count: result.failed ?? 0,
              recipients: result.recipients ?? 0,
              sent_at: new Date().toISOString(),
              updated_at: new Date().toISOString(),
              error_message: null,
            })
            .eq('id', row.id)
        }
        toast.success(msg.text)
      }
      onSaved()
      onOpenChange(false)
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Send failed')
    } finally {
      setSaving(false)
    }
  }

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent className="overflow-y-auto">
        <SheetHeader>
          <SheetTitle>{isNew ? 'New broadcast' : 'Edit broadcast'}</SheetTitle>
          <SheetDescription>
            Save as draft, or send to all devices with an FCM token. Deep link opens in the app when
            supported.
          </SheetDescription>
        </SheetHeader>
        <form onSubmit={onSaveDraft} className="mt-6 flex flex-col gap-5">
          <div className="flex flex-col gap-2">
            <Label htmlFor="push-title">Title</Label>
            <Input
              id="push-title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              required
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="push-body">Body</Label>
            <Textarea
              id="push-body"
              rows={5}
              value={body}
              onChange={(e) => setBody(e.target.value)}
              required
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="push-link">Deep link</Label>
            <Input
              id="push-link"
              value={deepLink}
              onChange={(e) => setDeepLink(e.target.value)}
              placeholder="/donate"
            />
          </div>
          {item?.error_message && (
            <p className="rounded-lg border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
              {item.error_message}
            </p>
          )}
          <SheetFooter>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Cancel
            </Button>
            <Button type="submit" variant="secondary" disabled={saving}>
              {saving ? 'Saving…' : 'Save draft'}
            </Button>
            <Button type="button" disabled={saving} onClick={() => void onSend()}>
              {saving ? 'Sending…' : item?.status === 'sent' ? 'Send again' : 'Send to all devices'}
            </Button>
          </SheetFooter>
        </form>
      </SheetContent>
    </Sheet>
  )
}
