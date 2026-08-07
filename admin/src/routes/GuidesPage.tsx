import { useMemo, useState } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { useRouteContext } from '@tanstack/react-router'
import type { ColumnDef } from '@tanstack/react-table'
import { Pencil, Plus, Settings2 } from 'lucide-react'
import { toast } from 'sonner'
import { DataTable } from '@/components/DataTable'
import { GuideHubFormSheet } from '@/components/GuideHubFormSheet'
import { GuideSectionFormSheet } from '@/components/GuideSectionFormSheet'
import { GuideStepFormSheet } from '@/components/GuideStepFormSheet'
import { PageHeader } from '@/components/PageHeader'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { isAdminRole, supabase } from '@/lib/supabase'
import type { GuideSection, GuideStep, PilgrimageHubSettings } from '@/lib/types'

function GuideStepsPanel({
  section,
  onEditSection,
}: {
  section: GuideSection
  onEditSection: () => void
}) {
  const queryClient = useQueryClient()
  const [stepSheetOpen, setStepSheetOpen] = useState(false)
  const [editing, setEditing] = useState<GuideStep | null>(null)

  const { data: steps = [], isLoading } = useQuery({
    queryKey: ['guide-steps', section.slug],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('guide_steps')
        .select('*')
        .eq('guide_slug', section.slug)
        .order('sort_order')
      if (error) throw error
      return data as GuideStep[]
    },
  })

  async function togglePublish() {
    const { error } = await supabase
      .from('guide_sections')
      .update({ published: !section.published, updated_at: new Date().toISOString() })
      .eq('slug', section.slug)
    if (error) {
      toast.error(error.message)
      return
    }
    toast.success(section.published ? 'Section unpublished' : 'Section published')
    await queryClient.invalidateQueries({ queryKey: ['guide-sections'] })
  }

  const columns: ColumnDef<GuideStep>[] = useMemo(
    () => [
      { header: '#', accessorKey: 'sort_order' },
      { header: 'Step', accessorKey: 'title' },
      {
        id: 'preview',
        header: 'Preview',
        cell: ({ row }) => {
          const s = row.original
          const subtitle = s.subtitle || (() => {
            try {
              const meta = JSON.parse(s.body) as { subtitle?: string; desc?: string }
              return meta.subtitle || meta.desc || ''
            } catch {
              return s.body?.slice(0, 60) ?? ''
            }
          })()
          return <span className="line-clamp-1 text-ink-muted">{subtitle}</span>
        },
      },
      {
        id: 'published',
        header: 'Status',
        cell: ({ row }) => (
          <Badge variant={row.original.published ? 'success' : 'draft'}>
            {row.original.published ? 'Published' : 'Hidden'}
          </Badge>
        ),
      },
      {
        id: 'actions',
        header: 'Actions',
        cell: ({ row }) => (
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={() => {
              setEditing(row.original)
              setStepSheetOpen(true)
            }}
          >
            <Pencil className="size-3.5 shrink-0" />
            <span className="hidden sm:inline">Edit</span>
          </Button>
        ),
      },
    ],
    []
  )

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="min-w-0">
          <div className="flex flex-wrap items-center gap-2">
            <p className="font-medium text-ink">{section.title}</p>
            <Badge variant={section.published ? 'success' : 'draft'}>
              {section.published ? 'Published' : 'Hidden'}
            </Badge>
            <Badge variant="secondary">{section.hub_group}</Badge>
          </div>
          {section.subtitle && <p className="text-sm text-ink-muted">{section.subtitle}</p>}
          <p className="mt-1 text-xs text-ink-muted">
            {section.slug} · {section.route} · sort {section.sort_order}
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Button type="button" size="sm" variant="outline" onClick={onEditSection}>
            <Settings2 className="size-3.5" />
            Edit section
          </Button>
          <Button type="button" size="sm" variant="secondary" onClick={() => void togglePublish()}>
            {section.published ? 'Unpublish' : 'Publish'}
          </Button>
          <Button
            type="button"
            size="sm"
            onClick={() => {
              setEditing(null)
              setStepSheetOpen(true)
            }}
          >
            <Plus className="size-3.5" />
            Add step
          </Button>
        </div>
      </div>

      {isLoading ? (
        <p className="text-sm text-ink-muted">Loading steps…</p>
      ) : (
        <DataTable
          data={steps}
          columns={columns}
          rowId={(row) => row.id}
          emptyMessage="No steps yet. Add the first step for this guide."
        />
      )}

      <GuideStepFormSheet
        open={stepSheetOpen}
        onOpenChange={setStepSheetOpen}
        guideSlug={section.slug}
        item={editing}
      />
    </div>
  )
}

export function GuidesPage() {
  const { role } = useRouteContext({ from: '/_admin' })
  const canEditHub = isAdminRole(role)
  const [hubSheetOpen, setHubSheetOpen] = useState(false)
  const [createOpen, setCreateOpen] = useState(false)
  const [editSection, setEditSection] = useState<GuideSection | null>(null)
  const [activeSlug, setActiveSlug] = useState<string | null>(null)

  const { data: sections = [], isLoading: sectionsLoading } = useQuery({
    queryKey: ['guide-sections'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('guide_sections')
        .select('*')
        .order('hub_group')
        .order('sort_order')
      if (error) throw error
      return data as GuideSection[]
    },
  })

  const { data: hubSetting, isLoading: hubLoading } = useQuery({
    queryKey: ['pilgrimage-hub'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('app_settings')
        .select('value')
        .eq('key', 'pilgrimage_hub')
        .single()
      if (error) throw error
      return data.value as PilgrimageHubSettings
    },
  })

  const currentSlug = activeSlug && sections.some((s) => s.slug === activeSlug)
    ? activeSlug
    : sections[0]?.slug

  return (
    <div>
      <PageHeader
        title="Guides"
        description="Umrah & Hajj hub plus learn guides (Wudu, How to Pray, What is Islam/Quran). Learn hub_group steps power dedicated mobile screens; Wudu/prayer steps may store JSON in the body field."
      >
        {canEditHub && (
          <Button type="button" size="sm" variant="outline" onClick={() => setHubSheetOpen(true)} disabled={hubLoading}>
            <Settings2 className="size-3.5" />
            Edit hub screen
          </Button>
        )}
        <Button type="button" size="sm" onClick={() => setCreateOpen(true)}>
          <Plus className="size-3.5" />
          New section
        </Button>
      </PageHeader>

      {sectionsLoading ? (
        <p className="mt-6 text-sm text-ink-muted">Loading sections…</p>
      ) : sections.length === 0 ? (
        <p className="mt-6 text-sm text-ink-muted">No guide sections yet. Create the first section.</p>
      ) : (
        <Tabs
          value={currentSlug}
          onValueChange={setActiveSlug}
          className="mt-6"
        >
          <TabsList>
            {sections.map((s) => (
              <TabsTrigger key={s.slug} value={s.slug} className="shrink-0">
                {s.title || s.slug}
              </TabsTrigger>
            ))}
          </TabsList>
          {sections.map((section) => (
            <TabsContent key={section.slug} value={section.slug} className="mt-4">
              <GuideStepsPanel
                section={section}
                onEditSection={() => setEditSection(section)}
              />
            </TabsContent>
          ))}
        </Tabs>
      )}

      <GuideHubFormSheet open={hubSheetOpen} onOpenChange={setHubSheetOpen} settings={hubSetting ?? null} />
      <GuideSectionFormSheet open={createOpen} onOpenChange={setCreateOpen} section={null} mode="create" />
      <GuideSectionFormSheet
        open={!!editSection}
        onOpenChange={(open) => !open && setEditSection(null)}
        section={editSection}
        mode="edit"
      />
    </div>
  )
}
