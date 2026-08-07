import { supabase } from '@/lib/supabase'

export type PushBroadcastResult = {
  ok?: boolean
  configured?: boolean
  message?: string
  sent?: number
  failed?: number
  recipients?: number
  broadcast_id?: string
}

/** Sends a push to all registered device_tokens via the push-broadcast edge function. */
export async function broadcastPush(input: {
  title: string
  body: string
  deepLink?: string
  broadcastId?: string
}): Promise<PushBroadcastResult> {
  const payload = {
    title: input.title.trim(),
    body: input.body.trim(),
    deep_link: input.deepLink?.trim() || '/donate',
    broadcast_id: input.broadcastId,
  }

  // Local Vite proxy avoids CORS preflight failures against Edge Functions.
  if (import.meta.env.DEV) {
    const {
      data: { session },
    } = await supabase.auth.getSession()
    if (!session?.access_token) {
      return { ok: false, message: 'Not signed in' }
    }
    const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string
    try {
      const res = await fetch('/__supabase/functions/v1/push-broadcast', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${session.access_token}`,
          apikey: anonKey,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
      })
      const data = (await res.json().catch(() => ({}))) as PushBroadcastResult
      if (!res.ok && !data.message) {
        return {
          ok: false,
          message: `Broadcast failed (${res.status}). Redeploy push-broadcast if the function is missing.`,
        }
      }
      return data
    } catch (err) {
      return {
        ok: false,
        message: err instanceof Error ? err.message : 'Broadcast request failed',
      }
    }
  }

  const { data, error } = await supabase.functions.invoke('push-broadcast', {
    body: payload,
  })
  if (error) {
    return { ok: false, message: error.message || 'Broadcast failed' }
  }
  return (data ?? {}) as PushBroadcastResult
}

export function pushResultToastMessage(result: PushBroadcastResult): {
  ok: boolean
  text: string
} {
  if (result.configured === false || result.ok === false) {
    return {
      ok: false,
      text:
        result.message ??
        'Push not configured. Open Help on Notifications for FCM setup.',
    }
  }
  if (result.sent === 0) {
    return {
      ok: true,
      text:
        result.message ??
        'No device tokens yet — users must allow notifications in the app.',
    }
  }
  return {
    ok: true,
    text: `Notification sent to ${result.sent} device(s)${result.failed ? ` (${result.failed} failed)` : ''}`,
  }
}
