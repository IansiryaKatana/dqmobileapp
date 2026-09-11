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
  DonateImpactCard,
  DonationEmailCopySettings,
  ExternalLinksSettings,
  HomeCampaignSettings,
  ImpactOverridesSettings,
  LegalDocumentsSettings,
  OnboardingSettings,
  OrderCatalogSettings,
  PermissionsSettings,
} from '@/lib/types'

const emptyCatalog: OrderCatalogSettings = {
  hero_title: '',
  hero_subtitle: '',
  languages: ['English', 'Arabic'],
  delivery_note: '',
  products: [],
}

const defaultImpactCards: DonateImpactCard[] = [
  { label: 'Sponsor 1 Quran', amount_label: '£5' },
  { label: 'Sponsor 5 Qurans', amount_label: '£25' },
  { label: 'Sponsor 10 Qurans', amount_label: '£50' },
  { label: 'Sponsor a Box', amount_label: '£250' },
]

const defaultDonate: DonateCopySettings = {
  tagline: '',
  guest_message: '',
  hero_title: 'Fund Quran printing today',
  hero_subtitle: 'Every £5 funds one Quran copy.',
  impact_cards: defaultImpactCards,
  checkout_store_note:
    'Payment uses the App Store / Play Store checkout via RevenueCat. Supported amounts: £5, £10, £25, £50, £100.',
  monthly_renew_note:
    'Monthly donations auto-renew at {{amount}} until you cancel in your Apple ID or Google Play subscription settings. Restore purchases from Profile if a receipt is missing.',
  success_title: 'May Allah reward you',
  success_subtitle: 'Your donation of {{amount}} has been received.',
}

const defaultOnboarding: OnboardingSettings = {
  brand: 'Donate Quran',
  intro_title: 'Give the gift\nof Quran',
  intro_subtitle: 'Donate, order, read and share the Quran\nthrough one trusted app.',
  intro_cta: 'GET STARTED',
  why_title: 'Why\nDonate Quran?',
  why_subtitle:
    'Your donation helps provide free Qurans to those who need them most. Together, we can spread the message and bring guidance to every heart.',
  skip_label: 'Skip',
  create_account_cta: 'Create Account',
  sign_in_cta: 'Sign In',
}

const defaultPermissions: PermissionsSettings = {
  title: 'Allow permissions',
  subtitle:
    'Enable notifications and location for the best experience — order updates, donation receipts, and accurate Qibla direction.',
  notifications_title: 'Notifications',
  notifications_description: 'Order updates, donation confirmations, and scholar replies.',
  location_title: 'Location',
  location_description: 'Used for Qibla direction and prayer times near you.',
  continue_label: 'Continue to app',
  skip_label: 'Not now',
}

const emptyLegal: LegalDocumentsSettings = {
  privacy_md: '',
  terms_md: '',
  support_md: '',
}

export function SettingsPage() {
  const queryClient = useQueryClient()
  const [home, setHome] = useState<HomeCampaignSettings>({ title: '', subtitle: '', link: '' })
  const [notifyHomeCampaign, setNotifyHomeCampaign] = useState(false)
  const [donate, setDonate] = useState<DonateCopySettings>(defaultDonate)
  const [impactCardsJson, setImpactCardsJson] = useState(JSON.stringify(defaultImpactCards, null, 2))
  const [onboarding, setOnboarding] = useState<OnboardingSettings>(defaultOnboarding)
  const [permissions, setPermissions] = useState<PermissionsSettings>(defaultPermissions)
  const [legal, setLegal] = useState<LegalDocumentsSettings>(emptyLegal)
  const [logisticsJson, setLogisticsJson] = useState('{\n  "groups": []\n}')
  const [catalog, setCatalog] = useState<OrderCatalogSettings>(emptyCatalog)
  const [catalogJson, setCatalogJson] = useState('')
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
    footer: 'Donations fund Quran printing. Store processing fees may apply; the remainder goes to printing.',
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
      const cards = Array.isArray(v.impact_cards) && v.impact_cards.length > 0 ? v.impact_cards : defaultImpactCards
      setDonate({
        tagline: v.tagline ?? '',
        guest_message: v.guest_message ?? '',
        hero_title: v.hero_title ?? defaultDonate.hero_title,
        hero_subtitle: v.hero_subtitle ?? defaultDonate.hero_subtitle,
        impact_cards: cards,
        checkout_store_note: v.checkout_store_note ?? defaultDonate.checkout_store_note,
        monthly_renew_note: v.monthly_renew_note ?? defaultDonate.monthly_renew_note,
        success_title: v.success_title ?? defaultDonate.success_title,
        success_subtitle: v.success_subtitle ?? defaultDonate.success_subtitle,
      })
      setImpactCardsJson(JSON.stringify(cards, null, 2))
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

    const legalVal = pick('legal_documents') as LegalDocumentsSettings | undefined
    if (legalVal) {
      setLegal({
        privacy_md: legalVal.privacy_md ?? '',
        terms_md: legalVal.terms_md ?? '',
        support_md: legalVal.support_md ?? '',
      })
    }

    const onboardVal = pick('onboarding') as OnboardingSettings | undefined
    if (onboardVal) {
      setOnboarding({ ...defaultOnboarding, ...onboardVal })
    }

    const permVal = pick('permissions') as PermissionsSettings | undefined
    if (permVal) {
      setPermissions({ ...defaultPermissions, ...permVal })
    }

    const logisticsVal = pick('logistics')
    if (logisticsVal) {
      setLogisticsJson(JSON.stringify(logisticsVal, null, 2))
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
    let impactCards = donate.impact_cards ?? defaultImpactCards
    try {
      const parsed = JSON.parse(impactCardsJson) as DonateImpactCard[]
      if (Array.isArray(parsed)) impactCards = parsed
    } catch {
      toast.error('Impact cards JSON is invalid')
      return
    }
    void upsert('donate_copy', {
      tagline: donate.tagline,
      guest_message: donate.guest_message,
      hero_title: donate.hero_title,
      hero_subtitle: donate.hero_subtitle,
      impact_cards: impactCards,
      checkout_store_note: donate.checkout_store_note,
      monthly_renew_note: donate.monthly_renew_note,
      success_title: donate.success_title,
      success_subtitle: donate.success_subtitle,
    })
  }

  function onSaveLegal(e: FormEvent) {
    e.preventDefault()
    void upsert('legal_documents', { ...legal })
  }

  function onSaveOnboarding(e: FormEvent) {
    e.preventDefault()
    void upsert('onboarding', { ...onboarding })
  }

  function onSavePermissions(e: FormEvent) {
    e.preventDefault()
    void upsert('permissions', { ...permissions })
  }

  function onSaveLogistics(e: FormEvent) {
    e.preventDefault()
    try {
      const value = JSON.parse(logisticsJson) as Record<string, unknown>
      void upsert('logistics', value)
    } catch {
      toast.error('Logistics JSON is invalid')
    }
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
        <div>
          <h3 className="font-semibold text-ink">Donate screen copy</h3>
          <p className="mt-1 text-xs text-ink-muted">
            Amount chips stay hardcoded (£5–£100) to match IAP products. Use{' '}
            <code>{'{{amount}}'}</code> in monthly / success copy.
          </p>
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="donate-hero-title">Hero title</Label>
          <Input
            id="donate-hero-title"
            value={donate.hero_title ?? ''}
            onChange={(e) => setDonate({ ...donate, hero_title: e.target.value })}
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="donate-hero-sub">Hero subtitle</Label>
          <Input
            id="donate-hero-sub"
            value={donate.hero_subtitle ?? ''}
            onChange={(e) => setDonate({ ...donate, hero_subtitle: e.target.value })}
          />
        </div>
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
        <div className="flex flex-col gap-2">
          <Label htmlFor="donate-checkout-note">Checkout store note</Label>
          <Textarea
            id="donate-checkout-note"
            rows={3}
            value={donate.checkout_store_note ?? ''}
            onChange={(e) => setDonate({ ...donate, checkout_store_note: e.target.value })}
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="donate-monthly">Monthly renew note</Label>
          <Textarea
            id="donate-monthly"
            rows={3}
            value={donate.monthly_renew_note ?? ''}
            onChange={(e) => setDonate({ ...donate, monthly_renew_note: e.target.value })}
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="donate-success-title">Success title</Label>
          <Input
            id="donate-success-title"
            value={donate.success_title ?? ''}
            onChange={(e) => setDonate({ ...donate, success_title: e.target.value })}
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="donate-success-sub">Success subtitle</Label>
          <Input
            id="donate-success-sub"
            value={donate.success_subtitle ?? ''}
            onChange={(e) => setDonate({ ...donate, success_subtitle: e.target.value })}
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="donate-impact-json">Impact cards JSON</Label>
          <Textarea
            id="donate-impact-json"
            rows={8}
            value={impactCardsJson}
            onChange={(e) => setImpactCardsJson(e.target.value)}
            className="font-mono text-xs"
          />
        </div>
        <Button type="submit" size="sm" className="self-start" disabled={saving === 'donate_copy'}>
          {saving === 'donate_copy' ? 'Saving…' : 'Save donate copy'}
        </Button>
      </form>

      <form onSubmit={onSaveOnboarding} className="mt-6 flex flex-col gap-4 rounded-xl border border-border bg-surface p-5 shadow-sm">
        <h3 className="font-semibold text-ink">Onboarding</h3>
        {(
          [
            ['brand', 'Brand'],
            ['intro_title', 'Intro title'],
            ['intro_subtitle', 'Intro subtitle'],
            ['intro_cta', 'Intro CTA'],
            ['why_title', 'Why title'],
            ['why_subtitle', 'Why subtitle'],
            ['skip_label', 'Skip'],
            ['create_account_cta', 'Create account'],
            ['sign_in_cta', 'Sign in'],
          ] as const
        ).map(([key, label]) => (
          <div key={key} className="flex flex-col gap-2">
            <Label htmlFor={`onboard-${key}`}>{label}</Label>
            {key.includes('subtitle') || key.includes('title') ? (
              <Textarea
                id={`onboard-${key}`}
                rows={key.includes('subtitle') ? 3 : 2}
                value={onboarding[key]}
                onChange={(e) => setOnboarding({ ...onboarding, [key]: e.target.value })}
              />
            ) : (
              <Input
                id={`onboard-${key}`}
                value={onboarding[key]}
                onChange={(e) => setOnboarding({ ...onboarding, [key]: e.target.value })}
              />
            )}
          </div>
        ))}
        <Button type="submit" size="sm" className="self-start" disabled={saving === 'onboarding'}>
          {saving === 'onboarding' ? 'Saving…' : 'Save onboarding'}
        </Button>
      </form>

      <form onSubmit={onSavePermissions} className="mt-6 flex flex-col gap-4 rounded-xl border border-border bg-surface p-5 shadow-sm">
        <h3 className="font-semibold text-ink">Permissions screen</h3>
        {(
          [
            ['title', 'Title'],
            ['subtitle', 'Subtitle'],
            ['notifications_title', 'Notifications title'],
            ['notifications_description', 'Notifications description'],
            ['location_title', 'Location title'],
            ['location_description', 'Location description'],
            ['continue_label', 'Continue'],
            ['skip_label', 'Skip / not now'],
          ] as const
        ).map(([key, label]) => (
          <div key={key} className="flex flex-col gap-2">
            <Label htmlFor={`perm-${key}`}>{label}</Label>
            {key.includes('subtitle') || key.includes('description') ? (
              <Textarea
                id={`perm-${key}`}
                rows={2}
                value={permissions[key]}
                onChange={(e) => setPermissions({ ...permissions, [key]: e.target.value })}
              />
            ) : (
              <Input
                id={`perm-${key}`}
                value={permissions[key]}
                onChange={(e) => setPermissions({ ...permissions, [key]: e.target.value })}
              />
            )}
          </div>
        ))}
        <Button type="submit" size="sm" className="self-start" disabled={saving === 'permissions'}>
          {saving === 'permissions' ? 'Saving…' : 'Save permissions'}
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

      <div className="mt-6 flex flex-col gap-3 rounded-xl border border-border bg-surface p-5 shadow-sm">
        <div>
          <h3 className="font-semibold text-ink">Order prices (PayPal)</h3>
          <p className="mt-1 text-xs text-ink-muted">
            Cost, postage, and totals are locked in app and Edge Function code (
            <code>order_pricing</code>
            ). CMS cannot change the amount PayPal charges. First Quran is free plus £7.50 P&amp;P;
            extra copies and boxes follow the published table. One PayPal payment for the Total.
          </p>
        </div>
        <ul className="list-disc space-y-1 pl-5 text-xs text-ink-muted">
          <li>1 copy: Free + £7.50 = £7.50</li>
          <li>2 copies: £10 + £2.50 = £12.50</li>
          <li>3–4 copies: £13 + £2.00 = £15.00</li>
          <li>5 copies: £15 + £2.50 = £17.50</li>
          <li>6–9 copies: £18 + £2.00 = £20.00</li>
          <li>Boxes (10 Qurans each): £25–£260 total depending on box count</li>
        </ul>
      </div>

      <form onSubmit={onSaveLegal} className="mt-6 flex flex-col gap-4 rounded-xl border border-border bg-surface p-5 shadow-sm">
        <div>
          <h3 className="font-semibold text-ink">Legal documents</h3>
          <p className="mt-1 text-xs text-ink-muted">
            In-app Privacy, Terms, and Support markdown. The public <code>site/*.html</code> pages are
            still deployed separately.
          </p>
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="legal-privacy">Privacy policy (markdown)</Label>
          <Textarea
            id="legal-privacy"
            rows={12}
            value={legal.privacy_md}
            onChange={(e) => setLegal({ ...legal, privacy_md: e.target.value })}
            className="font-mono text-xs"
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="legal-terms">Terms (markdown)</Label>
          <Textarea
            id="legal-terms"
            rows={12}
            value={legal.terms_md}
            onChange={(e) => setLegal({ ...legal, terms_md: e.target.value })}
            className="font-mono text-xs"
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="legal-support">Support (markdown)</Label>
          <Textarea
            id="legal-support"
            rows={10}
            value={legal.support_md}
            onChange={(e) => setLegal({ ...legal, support_md: e.target.value })}
            className="font-mono text-xs"
          />
        </div>
        <Button type="submit" size="sm" className="self-start" disabled={saving === 'legal_documents'}>
          {saving === 'legal_documents' ? 'Saving…' : 'Save legal documents'}
        </Button>
      </form>

      <form onSubmit={onSaveLogistics} className="mt-6 flex flex-col gap-4 rounded-xl border border-border bg-surface p-5 shadow-sm">
        <div>
          <h3 className="font-semibold text-ink">Logistics</h3>
          <p className="mt-1 text-xs text-ink-muted">
            Nested groups/items JSON (<code>label</code>, <code>title</code>, <code>snippet</code>,{' '}
            <code>icon</code> name, <code>kind</code>, <code>tips</code>, <code>ihram_steps</code>,{' '}
            <code>visa_cards</code>). Images stay on App media.
          </p>
        </div>
        <Textarea
          rows={16}
          value={logisticsJson}
          onChange={(e) => setLogisticsJson(e.target.value)}
          className="font-mono text-xs"
        />
        <Button type="submit" size="sm" className="self-start" disabled={saving === 'logistics'}>
          {saving === 'logistics' ? 'Saving…' : 'Save logistics'}
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
            Templates for the <code>donation-email</code> edge function. Intro and footer also
            show on the in-app donate success screen. Placeholders:{' '}
            <code>{'{{receipt_id}}'}</code>, <code>{'{{amount}}'}</code>,{' '}
            <code>{'{{donor_name}}'}</code>. Do not imply an email was sent from the app.
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
