export type GuideSection = {
  slug: string
  title: string
  subtitle: string
  badge: string
  icon: string
  hub_group: 'journey' | 'explore' | 'learn'
  route: string
  published: boolean
  sort_order: number
  updated_at?: string
}

export type GuideStep = {
  id: string
  guide_slug: string
  title: string
  /** Plain-text body for article-style guides, or legacy JSON blob */
  body: string
  subtitle?: string
  description?: string
  arabic?: string | null
  arabic_en?: string | null
  icon?: string
  icon_url?: string | null
  repeat_label?: string | null
  time_label?: string | null
  rakaat?: number | null
  accent?: string | null
  published: boolean
  sort_order: number
}

export type PilgrimageHubSettings = {
  eyebrow: string
  title: string
  disclaimer: string
  ayah_ar?: string
  ayah_en?: string
  ayah_ref?: string
}

export type StaffRole = 'user' | 'editor' | 'admin'

export type AppPageMedia = {
  id: string
  page_key: string
  slot_key: string
  label: string
  description: string
  media_type: 'image' | 'icon'
  url: string | null
  fallback_asset: string | null
  sort_order: number
  updated_at?: string
}

export type ProfileRow = {
  id: string
  email: string
  name: string
  role: StaffRole
  created_at: string
}

export type ContentItem = {
  id: string
  slug: string
  title: string
  summary: string
  body: string
  topic: string
  kind: 'article' | 'book' | 'campaign'
  image_url: string | null
  published: boolean
  sort_order: number
  updated_at: string
}

export type FaqItem = {
  id: string
  question: string
  answer: string
  published: boolean
  sort_order: number
}

export type QuranTopic = {
  id: string
  name: string
  description: string
  surah_numbers: number[]
  published: boolean
  sort_order: number
}

export type AppSetting = {
  key: string
  value: Record<string, unknown>
  description: string | null
  updated_at: string
}

export type HomeCampaignSettings = {
  title: string
  subtitle: string
  link?: string
}

export type DonateImpactCard = {
  label: string
  amount_label: string
}

export type DonateCopySettings = {
  tagline: string
  guest_message: string
  hero_title?: string
  hero_subtitle?: string
  impact_cards?: DonateImpactCard[]
  checkout_store_note?: string
  monthly_renew_note?: string
  success_title?: string
  success_subtitle?: string
}

export type LegalDocumentsSettings = {
  privacy_md: string
  terms_md: string
  support_md: string
}

export type OnboardingSettings = {
  brand: string
  intro_title: string
  intro_subtitle: string
  intro_cta: string
  why_title: string
  why_subtitle: string
  skip_label: string
  create_account_cta: string
  sign_in_cta: string
}

export type PermissionsSettings = {
  title: string
  subtitle: string
  notifications_title: string
  notifications_description: string
  location_title: string
  location_description: string
  continue_label: string
  skip_label: string
}

export type OrderCatalogProduct = {
  title: string
  description: string
  route_title: string
  qty_label: string
  cta: string
  pack_kind?: 'copies' | 'boxes'
  min_qty?: number
  max_qty?: number
}

export type OrderCatalogSettings = {
  hero_title: string
  hero_subtitle: string
  languages: string[]
  delivery_note: string
  products: OrderCatalogProduct[]
}

export type PostageSettings = {
  product_id: string
  display_pence: number
  display_label: string
}

export type AboutSettings = {
  title: string
  body: string
}

export type ExternalLinksSettings = {
  privacy: string
  terms: string
  distributor: string
  support: string
}

export type ImpactOverridesSettings = {
  qurans_funded: number | null
  orders_placed: number | null
  countries: number | null
}

export type DonationEmailCopySettings = {
  subject_template: string
  intro: string
  footer: string
}

export type PushDefaultsSettings = {
  default_deep_link: string
  firebase_console_hint?: string
}

export type PushBroadcast = {
  id: string
  title: string
  body: string
  deep_link: string
  status: 'draft' | 'sent' | 'failed'
  sent_count: number
  failed_count: number
  recipients: number
  error_message: string | null
  created_by: string | null
  created_at: string
  updated_at: string
  sent_at: string | null
}

export type DonationMetadata = {
  donor_email?: string
  donor_name?: string
  on_behalf_of?: string
  [key: string]: unknown
}

export type DonationRow = {
  id: string
  amount_pence: number
  currency: string
  frequency: string
  status: string
  receipt_id: string | null
  created_at: string
  user_id: string | null
  metadata: DonationMetadata
}

export type OrderStatus =
  | 'pending'
  | 'paid'
  | 'processing'
  | 'shipped'
  | 'delivered'
  | 'cancelled'

export const ORDER_STATUSES: OrderStatus[] = [
  'pending',
  'paid',
  'processing',
  'shipped',
  'delivered',
  'cancelled',
]

export type OrderAddress = {
  line1?: string
  line2?: string
  city?: string
  region?: string
  postcode?: string
  country?: string
  name?: string
  phone?: string
  [key: string]: unknown
}

export type OrderRow = {
  id: string
  reference: string
  quantity: number
  language: string
  status: string
  cost_pence: number
  postage_pence: number
  address: OrderAddress | null
  created_at: string
  user_id: string | null
  paypal_order_id?: string | null
  stripe_payment_intent_id?: string | null
  payment_provider?: string | null
}

export type ScholarStatus = 'submitted' | 'in_review' | 'answered' | 'closed'

export const SCHOLAR_STATUSES: ScholarStatus[] = [
  'submitted',
  'in_review',
  'answered',
  'closed',
]

export type ScholarQuestionRow = {
  id: string
  name: string
  email: string
  topic: string
  question: string
  status: string
  answer: string | null
  answered_at: string | null
  answered_by: string | null
  created_at: string
  user_id: string | null
}

export type ImpactStats = {
  qurans_funded: number
  orders_placed: number
  countries: number
}
