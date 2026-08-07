import { FormEvent, useState } from 'react'

import { useNavigate } from '@tanstack/react-router'

import { supabase } from '@/lib/supabase'

import { Button } from '@/components/ui/button'

import { Input } from '@/components/ui/input'

import { Label } from '@/components/ui/label'



export function LoginPage() {

  const navigate = useNavigate()

  const [email, setEmail] = useState('')

  const [password, setPassword] = useState('')

  const [error, setError] = useState<string | null>(null)

  const [loading, setLoading] = useState(false)



  async function onSubmit(e: FormEvent) {

    e.preventDefault()

    setLoading(true)

    setError(null)

    const { data, error: signInError } = await supabase.auth.signInWithPassword({ email, password })

    if (signInError) {

      setError(signInError.message)

      setLoading(false)

      return

    }

    const { data: profile } = await supabase.from('profiles').select('role').eq('id', data.user.id).maybeSingle()

    if (!profile || !['editor', 'admin'].includes(profile.role)) {

      await supabase.auth.signOut()

      setError('This account does not have staff access. Ask an admin to set role to editor or admin.')

      setLoading(false)

      return

    }

    await navigate({ to: '/' })

    setLoading(false)

  }



  return (

    <div className="flex min-h-dvh items-center justify-center bg-cream p-4 pt-[max(1rem,env(safe-area-inset-top))] pb-[max(1rem,env(safe-area-inset-bottom))] sm:p-6">

      <form onSubmit={onSubmit} className="w-full max-w-md rounded-2xl border border-border bg-surface p-6 shadow-sm sm:p-8">

        <p className="text-xs font-semibold tracking-widest text-accent uppercase">Donate Quran</p>

        <h1 className="mt-2 text-2xl font-bold text-ink">Staff sign in</h1>

        <p className="mt-2 text-sm text-ink-muted">CMS for content, FAQ, and operations</p>

        <div className="mt-6 flex flex-col gap-2">

          <Label htmlFor="email">Email</Label>

          <Input

            id="email"

            type="email"

            required

            value={email}

            onChange={(e) => setEmail(e.target.value)}

          />

        </div>

        <div className="mt-4 flex flex-col gap-2">

          <Label htmlFor="password">Password</Label>

          <Input

            id="password"

            type="password"

            required

            value={password}

            onChange={(e) => setPassword(e.target.value)}

          />

        </div>

        {error && <p className="mt-4 text-sm text-danger">{error}</p>}

        <Button type="submit" disabled={loading} className="mt-6 w-full">

          {loading ? 'Signing in…' : 'Sign in'}

        </Button>

      </form>

    </div>

  )

}

