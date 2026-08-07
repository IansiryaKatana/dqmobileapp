import { FormEvent, useEffect, useState } from 'react'

import { Link } from '@tanstack/react-router'

import { useQuery, useQueryClient } from '@tanstack/react-query'

import { toast } from 'sonner'

import { PageHeader } from '@/components/PageHeader'

import { Button } from '@/components/ui/button'

import { Input } from '@/components/ui/input'

import { Label } from '@/components/ui/label'
import { supabase } from '@/lib/supabase'



type RevenueCatConfig = {

  offering_id?: string

  monthly_package_id?: string

  note?: string

}



export function RevenueCatPage() {

  const queryClient = useQueryClient()

  const [offeringId, setOfferingId] = useState('default')

  const [monthlyPackageId, setMonthlyPackageId] = useState('monthly')



  const { data } = useQuery({

    queryKey: ['revenuecat-setting'],

    queryFn: async () => {

      const { data, error } = await supabase.from('app_settings').select('value').eq('key', 'revenuecat').maybeSingle()

      if (error) throw error

      return (data?.value ?? {}) as RevenueCatConfig

    },

  })



  useEffect(() => {

    if (data) {

      setOfferingId(data.offering_id ?? 'default')

      setMonthlyPackageId(data.monthly_package_id ?? 'monthly')

    }

  }, [data])



  async function onSubmit(e: FormEvent) {

    e.preventDefault()

    const value: RevenueCatConfig = {

      offering_id: offeringId,

      monthly_package_id: monthlyPackageId,

      note: 'API keys are set in mobile CI env only — not stored here.',

    }

    const { error } = await supabase

      .from('app_settings')

      .upsert({ key: 'revenuecat', value, description: 'RevenueCat offering configuration (no secrets)', updated_at: new Date().toISOString() })

    if (error) {

      toast.error(error.message)

      return

    }

    toast.success('Saved offering configuration')

    await queryClient.invalidateQueries({ queryKey: ['revenuecat-setting'] })

  }



  return (

    <div className="max-w-2xl">

      <Link to="/settings" className="text-sm font-medium text-accent hover:underline">

        ← App settings

      </Link>

      <PageHeader

        title="RevenueCat"

        description="Donate Quran uses RevenueCat only for in-app purchases and subscriptions."

      />



      <div className="mt-6 rounded-xl border border-accent/30 bg-accent-soft p-4 text-sm text-ink">

        <p className="font-semibold">Secrets stay out of the admin</p>

        <ul className="mt-2 list-inside list-disc text-ink-muted">

          <li>API keys — mobile .env and Codemagic only</li>

          <li>Webhook secret — Supabase Edge Function env</li>

          <li>This page only stores public offering/package identifiers</li>

        </ul>

      </div>



      <form onSubmit={onSubmit} className="mt-8 flex flex-col gap-4 rounded-xl border border-border bg-surface p-5 shadow-sm">

        <div className="flex flex-col gap-2">

          <Label htmlFor="offering">Offering ID</Label>

          <Input id="offering" value={offeringId} onChange={(e) => setOfferingId(e.target.value)} />

        </div>

        <div className="flex flex-col gap-2">

          <Label htmlFor="package">Monthly package ID</Label>

          <Input id="package" value={monthlyPackageId} onChange={(e) => setMonthlyPackageId(e.target.value)} />

        </div>

        <Button type="submit" className="self-start">Save</Button>

      </form>



      <p className="mt-8 text-sm text-ink-muted">

        Manage products in the{' '}

        <a href="https://app.revenuecat.com" target="_blank" rel="noreferrer" className="font-medium text-accent hover:underline">

          RevenueCat dashboard

        </a>

        .

      </p>

    </div>

  )

}

