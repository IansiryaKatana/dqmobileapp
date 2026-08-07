import type { ContentItem } from '@/lib/types'

export type ContentKind = ContentItem['kind']

export const CONTENT_KIND_META: Record<
  ContentKind,
  { label: string; plural: string; addLabel: string; description: string }
> = {
  article: {
    label: 'Article',
    plural: 'Articles',
    addLabel: 'Add new article',
    description: 'Educational articles shown in the app learn section.',
  },
  book: {
    label: 'Book',
    plural: 'Books',
    addLabel: 'Add new book',
    description: 'Book entries and reading guides for the mobile app.',
  },
  campaign: {
    label: 'Campaign',
    plural: 'Campaigns',
    addLabel: 'Add new campaign',
    description:
      'Campaign content items. Note: the home Featured Campaign card is driven by App Settings → home_campaign, not this list.',
  },
}

export const CONTENT_KINDS: ContentKind[] = ['article', 'book', 'campaign']
