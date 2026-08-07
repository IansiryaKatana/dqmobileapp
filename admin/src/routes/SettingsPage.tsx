import { FormEvent, useEffect, useState } from 'react'
import { Link } from '@tanstack/react-router'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { PageHeader } from '@/components/PageHeader'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Checkbox } from '@/components/ui/checkbox'
import { supabase } from '@/lib/supabase'
import { broadcastPush, pushResultToastMessage } from '@/lib/push'
import type {
  AboutSettings,
  AppSetting,
  DonateCopySettings,
  DonationEmailCopySettings,
  ExternalLinksSettings,
  HomeCampaignSettings,
  ImpactOverridesSettings,
  OrderCatalogSettings,
  PostageSettings,
} from '@/lib/types'

const emptyCatalog: OrderCatalogSettings = {
  hero_title: '',
  hero_subtitle: '',
  languages: ['English', 'Arabic'],
  delivery_note: '',
  products: [],
}

export function SettingsPage() {
  const queryClient = useQueryClient()
  const [home, setHome] = useState<HomeCampaignSettings>({ title: '', subtitle: '', link: '' })
  const [notifyHomeCampaign, setNotifyHomeCampaign] = useState(false)
  const [donate, setDonate] = useState<DonateCopySettings>({ tagline: '', guest_message: '' })
  const [catalog, setCatalog] = useState<OrderCatalogSettings>(emptyCatalog)
  const [catalogJson, setCatalogJson] = useState('')
  const [postage, setPostage] = useState<PostageSettings>({
    product_id: 'dq_postage_399',
    display_pence: 399,
    display_label: '£3.99',
  })
  const [about, setAbout] = useState<AboutSettings>({ title: 'About Us', body: '' })
  const [links, setLinks] = useState<ExternalLinksSettings>({
    privacy: '',
    terms: '',
    distributor: '',
    support: '',
  })
  const [impact, setImpact] = useState<ImpactOverridesSettings>({
    qurans_funded: null,
    orders_placed: null,
    countries: null,
  })
  const [emailCopy, setEmailCopy] = useState<DonationEmailCopySettings>({
    subject_template: 'Donation receipt {{receipt_id}}',
    intro: 'Your gift of {{amount}} helps print and distribute Qurans.',
    footer: '100% of public donations go towards Quran printing.',
  })
  const [showAdvanced, setShowAdvanced] = useState(false)
  const [homeJson, setHomeJson] = useState('')
  const [donateJson, setDonateJson] = useState('')
  const [saving, setSaving] = useState<string | null>(null)

  const { data } = useQuery({
    queryKey: ['app-settings'],
    queryFn: async () => {
      const { data, error } = await supabase.from('app_settings').select('*')
      if (error) throw error
      return data as AppSetting[]
    },
  })

  useEffect(() => {
    if (!data) return
    const pick = (key: string) => data.find((s) => s.key === key)?.value

    const homeRow = data.find((s) => s.key === 'home_campaign')
    const donateRow = data.find((s) => s.key === 'donate_copy')
    if (homeRow) {
      const v = homeRow.value as HomeCampaignSettings
      setHome({ title: v.title ?? '', subtitle: v.subtitle ?? '', link: v.link ?? '' })
      setHomeJson(JSON.stringify(homeRow.value, null, 2))
    }
    if (donateRow) {
      const v = donateRow.value as DonateCopySettings
      setDonate({ tagline: v.tagline ?? '', guest_message: v.guest_message ?? '' })
      setDonateJson(JSON.stringify(donateRow.value, null, 2))
    }

    const cat = pick('order_catalog') as OrderCatalogSettings | undefined
    if (cat) {
      setCatalog({
        hero_title: cat.hero_title ?? '',
        hero_subtitle: cat.hero_subtitle ?? '',
        languages: Array.isArray(cat.languages) ? cat.languages : ['English', 'Arabic'],
        delivery_note: cat.delivery_note ?? '',
        products: Array.isArray(cat.products) ? cat.products : [],
      })
      setCatalogJson(JSON.stringify(cat, null, 2))
    }

    const post = pick('postage') as PostageSettings | undefined
    if (post) {
      setPostage({
        product_id: post.product_id ?? 'dq_postage_399',
        display_pence: Number(post.display_pence) || 399,
        display_label: post.display_label ?? '£3.99',
      })
    }

    const aboutVal = pick('about') as AboutSettings | undefined
    if (aboutVal) {
      setAbout({ title: aboutVal.title ?? 'About Us', body: aboutVal.body ?? '' })
    }

    const ext = pick('external_links') as ExternalLinksSettings | undefined
    if (ext) {
      setLinks({
        privacy: ext.privacy ?? '',
        terms: ext.terms ?? '',
        distributor: ext.distributor ?? '',
        support: ext.support ?? '',
      })
    }

    const ov = pick('impact_overrides') as ImpactOverridesSettings | undefined
    if (ov) {
      setImpact({
        qurans_funded: ov.qurans_funded ?? null,
        orders_placed: ov.orders_placed ?? null,
        countries: ov.countries ?? null,
      })
    }

    const em = pick('donation_email_copy') as DonationEmailCopySettings | undefined
    if (em) {
      setEmailCopy({
        subject_template: em.subject_template ?? '',
        intro: em.intro ?? '',
        footer: em.footer ?? '',
      })
    }
  }, [data])

  async function upsert(key: string, value: Record<string, unknown>) {
    setSaving(key)
    const { error } = await supabase
      .from('app_settings')
      .upsert({ key, value, updated_at: new Date().toISOString() })
    setSaving(null)
    if (error) {
      toast.error(error.message)
      return
    }
    toast.success(`Saved ${key}`)
    await queryClient.invalidateQueries({ queryKey: ['app-settings'] })
    await queryClient.invalidateQueries({ queryKey: ['dashboard-stats'] })
  }

  async function onSaveHome(e: FormEvent) {
    e.preventDefault()
    setSaving('home_campaign')
    const value = {
      title: home.title,
      subtitle: home.subtitle,
      ...(home.link?.trim() ? { link: home.link.trim() } : { link: home.link ?? '' }),
    }
    const { error } = await supabase
      .from('app_settings')
      .upsert({ key: 'home_campaign', value, updated_at: new Date().toISOString() })
    if (error) {
      setSaving(null)
      toast.error(error.message)
      return
    }
    if (notifyHomeCampaign) {
      const result = await broadcastPush({
        title: home.title,
        body: home.subtitle || 'New campaign on Donate Quran',
        deepLink: home.link?.startsWith('/') ? home.link : '/donate',
      })
      const msg = pushResultToastMessage(result)
      if (msg.ok) toast.success(`Home campaign saved — ${msg.text}`)
      else toast.warning(`Home campaign saved, but push failed: ${msg.text}`)
    } else {
      toast.success('Saved home_campaign')
    }
    setSaving(null)
    setNotifyHomeCampaign(false)
    await queryClient.invalidateQueries({ queryKey: ['app-settings'] })
    await queryClient.invalidateQueries({ queryKey: ['dashboard-stats'] })
  }

  function onSaveDonate(e: FormEvent) {
    e.preventDefault()
    void upsert('donate_copy', {
      tagline: donate.tagline,
      guest_message: donate.guest_message,
    })
  }

  function onSaveCatalog(e: FormEvent) {
    e.preventDefault()
    let products = catalog.products
    try {
      const parsed = JSON.parse(catalogJson) as OrderCatalogSettings
      if (Array.isArray(parsed.products)) products = parsed.products
    } catch {
      toast.error('Catalog JSON is invalid — fix products JSON or reset from saved data')
      return
    }
    void upsert('order_catalog', {
      hero_title: catalog.hero_title,
      hero_subtitle: catalog.hero_subtitle,
      languages: catalog.languages,
      delivery_note: catalog.delivery_note,
      products,
    })
  }

  function onSavePostage(e: FormEvent) {
    e.preventDefault()
    void upsert('postage', {
      product_id: postage.product_id.trim() || 'dq_postage_399',
      display_pence: Number(postage.display_pence) || 399,
      display_label: postage.display_label,
    })
  }

  function onSaveAbout(e: FormEvent) {
    e.preventDefault()
    void upsert('about', { title: about.title, body: about.body })
  }

  function onSaveLinks(e: FormEvent) {
    e.preventDefault()
    void upsert('external_links', { ...links })
  }

  function onSaveImpact(e: FormEvent) {
    e.preventDefault()
    void upsert('impact_overrides', {
      qurans_funded: impact.qurans_funded,
      orders_placed: impact.orders_placed,
      countries: impact.countries,
    })
  }

  function onSaveEmail(e: FormEvent) {
    e.preventDefault()
    void upsert('donation_email_copy', { ...emailCopy })
  }

  async function saveJson(key: string, json: string) {
    try {
      const value = JSON.parse(json) as Record<string, unknown>
      await upsert(key, value)
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Invalid JSON')
    }
  }

  function floorField(
    label: string,
    key: keyof ImpactOverridesSettings,
  ) {
    const val = impact[key]
    return (
      <div className="flex flex-col gap-2">
        <Label htmlFor={`impact-${key}`}>{label}</Label>
        <Input
          id={`impact-${key}`}
          type="number"
          min={0}
          placeholder="No override"
          value={val ?? ''}
          onChange={(e) => {
            const raw = e.target.value
            setImpact({
              ...impact,
              [key]: raw === '' ? null : Number(raw),
            })
          }}
        />
      </div>
    )
  }

  return (
    <div className="max-w-3xl">
      <PageHeader
        title="App settings"
        description="Non-secret copy and feature flags consumed by the mobile app. Admin only."
      />
      <div className="mt-4 flex flex-wrap gap-4 text-sm font-medium">
        <Link to="/settings/revenuecat" className="text-accent hover:underline">
          RevenueCat offering IDs →
        </Link>
        <Link to="/notifications" className="text-accent hover:underline">
          Push notifications →
        </Link>
      </div>

      <form onSubmit={onSaveHome} className="mt-8 flex flex-col gap-4 rounded-xl border border-border bg-surface p-5 shadow-sm">
        <div>
          <h3 className="font-semibold text-ink">Home featured campaign</h3>
          <p className="mt-1 text-xs text-ink-muted">
            Drives the home screen Featured Campaign card via <code>home_campaign</code>.
          </p>
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="home-title">Title</Label>
          <Input
            id="home-title"
            value={home.title}
            onChange={(e) => setHome({ ...home, title: e.target.value })}
            required
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="home-subtitle">Subtitle</Label>
          <Input
            id="home-subtitle"
            value={home.subtitle}
            onChange={(e) => setHome({ ...home, subtitle: e.target.value })}
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="home-link">Link (optional)</Label>
          <Input
            id="home-link"
            value={home.link ?? ''}
            onChange={(e) => setHome({ ...home, link: e.target.value })}
            placeholder="https://…"
          />
        </div>
        <label className="flex items-center gap-2 text-sm">
          <Checkbox
            checked={notifyHomeCampaign}
            onCheckedChange={(v) => setNotifyHomeCampaign(v === true)}
          />
          Also notify app users (push) when saving
        </label>
        <Button type="submit" size="sm" className="self-start" disabled={saving === 'home_campaign'}>
          {saving === 'home_campaign' ? 'Saving…' : 'Save home campaign'}
        </Button>
      </form>

      <form onSubmit={onSaveDonate} className="mt-6 flex flex-col gap-4 rounded-xl border border-border bg-surface p-5 shadow-sm">
        <h3 className="font-semibold text-ink">Donate screen copy</h3>
        <div className="flex flex-col gap-2">
          <Label htmlFor="donate-tagline">Tagline</Label>
          <Input
            id="donate-tagline"
            value={donate.tagline}
            onChange={(e) => setDonate({ ...donate, tagline: e.target.value })}
            required
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="donate-guest">Guest message</Label>
          <Input
            id="donate-guest"
            value={donate.guest_message}
            onChange={(e) => setDonate({ ...donate, guest_message: e.target.value })}
          />
        </div>
        <Button type="submit" size="sm" className="self-start" disabled={saving === 'donate_copy'}>
          {saving === 'donate_copy' ? 'Saving…' : 'Save donate copy'}
        </Button>
      </form>

      <form onSubmit={onSaveCatalog} className="mt-6 flex flex-col gap-4 rounded-xl border border-border bg-surface p-5 shadow-sm">
        <div>
          <h3 className="font-semibold text-ink">Order catalog</h3>
          <p className="mt-1 text-xs text-ink-muted">
            Hero copy, languages, delivery note, and product cards (<code>order_catalog</code>). Edit
            product list as JSON below the quick fields.
          </p>
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="cat-hero">Hero title</Label>
          <Input
            id="cat-hero"
            value={catalog.hero_title}
            onChange={(e) => setCatalog({ ...catalog, hero_title: e.target.value })}
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="cat-sub">Hero subtitle</Label>
          <Input
            id="cat-sub"
            value={catalog.hero_subtitle}
            onChange={(e) => setCatalog({ ...catalog, hero_subtitle: e.target.value })}
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="cat-langs">Languages (comma-separated)</Label>
          <Input
            id="cat-langs"
            value={catalog.languages.join(', ')}
            onChange={(e) =>
              setCatalog({
                ...catalog,
                languages: e.target.value.split(',').map((s) => s.trim()).filter(Boolean),
              })
            }
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="cat-note">Delivery note</Label>
          <Input
            id="cat-note"
            value={catalog.delivery_note}
            onChange={(e) => setCatalog({ ...catalog, delivery_note: e.target.value })}
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="cat-json">Full catalog JSON (includes products)</Label>
          <Textarea
            id="cat-json"
            rows={12}
            value={catalogJson}
            onChange={(e) => setCatalogJson(e.target.value)}
            className="font-mono text-xs"
          />
        </div>
        <Button type="submit" size="sm" className="self-start" disabled={saving === 'order_catalog'}>
          {saving === 'order_catalog' ? 'Saving…' : 'Save order catalog'}
        </Button>
      </form>

      <form onSubmit={onSavePostage} className="mt-6 flex flex-col gap-4 rounded-xl border border-border bg-surface p-5 shadow-sm">
        <div>
          <h3 className="font-semibold text-ink">Postage display</h3>
          <p className="mt-1 text-xs text-ink-muted">
            CMS can change displayed pence/label used by mobile. Changing the real IAP price still
            requires App Store / Play Console and RevenueCat product{' '}
            <code>dq_postage_399</code> to stay in sync — do not rename the product ID casually.
          </p>
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="post-id">Product ID</Label>
          <Input
            id="post-id"
            value={postage.product_id}
            onChange={(e) => setPostage({ ...postage, product_id: e.target.value })}
          />
        </div>
        <div className="grid gap-4 sm:grid-cols-2">
          <div className="flex flex-col gap-2">
            <Label htmlFor="post-pence">Display pence</Label>
            <Input
              id="post-pence"
              type="number"
              min={0}
              value={postage.display_pence}
              onChange={(e) => setPostage({ ...postage, display_pence: Number(e.target.value) })}
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="post-label">Display label</Label>
            <Input
              id="post-label"
              value={postage.display_label}
              onChange={(e) => setPostage({ ...postage, display_label: e.target.value })}
            />
          </div>
        </div>
        <Button type="submit" size="sm" className="self-start" disabled={saving === 'postage'}>
          {saving === 'postage' ? 'Saving…' : 'Save postage'}
        </Button>
      </form>

      <form onSubmit={onSaveAbout} className="mt-6 flex flex-col gap-4 rounded-xl border border-border bg-surface p-5 shadow-sm">
        <h3 className="font-semibold text-ink">About Us</h3>
        <div className="flex flex-col gap-2">
          <Label htmlFor="about-title">Title</Label>
          <Input
            id="about-title"
            value={about.title}
            onChange={(e) => setAbout({ ...about, title: e.target.value })}
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="about-body">Body</Label>
          <Textarea
            id="about-body"
            rows={5}
            value={about.body}
            onChange={(e) => setAbout({ ...about, body: e.target.value })}
          />
        </div>
        <Button type="submit" size="sm" className="self-start" disabled={saving === 'about'}>
          {saving === 'about' ? 'Saving…' : 'Save about'}
        </Button>
      </form>

      <form onSubmit={onSaveLinks} className="mt-6 flex flex-col gap-4 rounded-xl border border-border bg-surface p-5 shadow-sm">
        <h3 className="font-semibold text-ink">External links</h3>
        <p className="text-xs text-ink-muted">Privacy, terms, distributor, and support web URLs.</p>
        {(['privacy', 'terms', 'distributor', 'support'] as const).map((key) => (
          <div key={key} className="flex flex-col gap-2">
            <Label htmlFor={`link-${key}`} className="capitalize">
              {key}
            </Label>
            <Input
              id={`link-${key}`}
              value={links[key]}
              onChange={(e) => setLinks({ ...links, [key]: e.target.value })}
              placeholder="https://…"
            />
          </div>
        ))}
        <Button type="submit" size="sm" className="self-start" disabled={saving === 'external_links'}>
          {saving === 'external_links' ? 'Saving…' : 'Save links'}
        </Button>
      </form>

      <form onSubmit={onSaveImpact} className="mt-6 flex flex-col gap-4 rounded-xl border border-border bg-surface p-5 shadow-sm">
        <div>
          <h3 className="font-semibold text-ink">Impact overrides</h3>
          <p className="mt-1 text-xs text-ink-muted">
            Optional floors. Mobile shows <code>max(computed, override)</code>. Leave blank for no
            override. See also Dashboard impact cards.
          </p>
        </div>
        {floorField('Qurans funded floor', 'qurans_funded')}
        {floorField('Orders placed floor', 'orders_placed')}
        {floorField('Countries / cities floor', 'countries')}
        <Button type="submit" size="sm" className="self-start" disabled={saving === 'impact_overrides'}>
          {saving === 'impact_overrides' ? 'Saving…' : 'Save impact overrides'}
        </Button>
      </form>

      <form onSubmit={onSaveEmail} className="mt-6 flex flex-col gap-4 rounded-xl border border-border bg-surface p-5 shadow-sm">
        <div>
          <h3 className="font-semibold text-ink">Donation email copy</h3>
          <p className="mt-1 text-xs text-ink-muted">
            Templates for the <code>donation-email</code> edge function. Placeholders:{' '}
            <code>{'{{receipt_id}}'}</code>, <code>{'{{amount}}'}</code>,{' '}
            <code>{'{{donor_name}}'}</code>.
          </p>
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="email-subject">Subject template</Label>
          <Input
            id="email-subject"
            value={emailCopy.subject_template}
            onChange={(e) => setEmailCopy({ ...emailCopy, subject_template: e.target.value })}
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="email-intro">Intro</Label>
          <Textarea
            id="email-intro"
            rows={3}
            value={emailCopy.intro}
            onChange={(e) => setEmailCopy({ ...emailCopy, intro: e.target.value })}
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="email-footer">Footer</Label>
          <Input
            id="email-footer"
            value={emailCopy.footer}
            onChange={(e) => setEmailCopy({ ...emailCopy, footer: e.target.value })}
          />
        </div>
        <Button type="submit" size="sm" className="self-start" disabled={saving === 'donation_email_copy'}>
          {saving === 'donation_email_copy' ? 'Saving…' : 'Save email copy'}
        </Button>
      </form>

      <div className="mt-8">
        <button
          type="button"
          className="text-sm font-medium text-accent hover:underline"
          onClick={() => setShowAdvanced((v) => !v)}
        >
          {showAdvanced ? 'Hide advanced JSON' : 'Show advanced JSON'}
        </button>
        {showAdvanced && (
          <div className="mt-4 space-y-6">
            <div className="flex flex-col gap-3 rounded-xl border border-border bg-surface p-5 shadow-sm">
              <h3 className="font-semibold text-ink">home_campaign (JSON)</h3>
              <Textarea
                rows={6}
                value={homeJson}
                onChange={(e) => setHomeJson(e.target.value)}
                className="font-mono text-xs"
              />
              <Button type="button" size="sm" className="self-start" onClick={() => void saveJson('home_campaign', homeJson)}>
                Save JSON
              </Button>
            </div>
            <div className="flex flex-col gap-3 rounded-xl border border-border bg-surface p-5 shadow-sm">
              <h3 className="font-semibold text-ink">donate_copy (JSON)</h3>
              <Textarea
                rows={6}
                value={donateJson}
                onChange={(e) => setDonateJson(e.target.value)}
                className="font-mono text-xs"
              />
              <Button type="button" size="sm" className="self-start" onClick={() => void saveJson('donate_copy', donateJson)}>
                Save JSON
              </Button>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
