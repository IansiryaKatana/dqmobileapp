import { useEffect, useMemo, useState, type ElementType } from 'react'
import { Link, Outlet, useRouteContext, useRouter, useRouterState } from '@tanstack/react-router'
import {
  Bell,
  BookMarked,
  BookOpen,
  ChevronDown,
  CircleHelp,
  CreditCard,
  FileText,
  HeartHandshake,
  ImageIcon,
  LayoutDashboard,
  ListTree,
  LogOut,
  Menu,
  MessageCircleQuestion,
  Package,
  Settings,
  Shield,
  Users,
} from 'lucide-react'
import { supabase, isAdminRole } from '@/lib/supabase'
import { Button } from '@/components/ui/button'
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@/components/ui/sheet'
import { cn } from '@/lib/utils'

type NavLeaf = {
  to: string
  label: string
  icon: ElementType
  adminOnly?: boolean
}

type NavGroup = {
  id: string
  label: string
  icon: ElementType
  adminOnly?: boolean
  children: NavLeaf[]
}

type NavEntry = NavLeaf | NavGroup

function isNavGroup(entry: NavEntry): entry is NavGroup {
  return 'children' in entry
}

const nav: NavEntry[] = [
  { to: '/', label: 'Dashboard', icon: LayoutDashboard },
  {
    id: 'content',
    label: 'Content',
    icon: FileText,
    children: [
      { to: '/content', label: 'Content', icon: FileText },
      { to: '/navigation', label: 'More Menu', icon: ListTree },
      { to: '/guides', label: 'Guides', icon: BookOpen },
      { to: '/app-media', label: 'App Media', icon: ImageIcon },
      { to: '/faq', label: 'FAQ', icon: CircleHelp },
      { to: '/topics', label: 'Quran Topics', icon: BookMarked },
    ],
  },
  {
    id: 'services',
    label: 'Services',
    icon: HeartHandshake,
    children: [
      { to: '/donations', label: 'Donations', icon: HeartHandshake },
      { to: '/orders', label: 'Orders', icon: Package },
      { to: '/scholar', label: 'Scholar Q&A', icon: MessageCircleQuestion },
    ],
  },
  {
    id: 'admin',
    label: 'Administration',
    icon: Shield,
    adminOnly: true,
    children: [
      { to: '/users', label: 'Users', icon: Users, adminOnly: true },
      { to: '/settings', label: 'App Settings', icon: Settings, adminOnly: true },
      { to: '/settings/revenuecat', label: 'RevenueCat', icon: CreditCard, adminOnly: true },
      { to: '/notifications', label: 'Notifications', icon: Bell, adminOnly: true },
    ],
  },
]

function filterNav(entries: NavEntry[], isAdmin: boolean): NavEntry[] {
  return entries.flatMap((entry) => {
    if (isNavGroup(entry)) {
      if (entry.adminOnly && !isAdmin) return []
      const children = entry.children.filter((child) => !child.adminOnly || isAdmin)
      if (children.length === 0) return []
      return [{ ...entry, children }]
    }
    if (entry.adminOnly && !isAdmin) return []
    return [entry]
  })
}

function pathMatches(pathname: string, to: string) {
  if (to === '/') return pathname === '/'
  return pathname === to || pathname.startsWith(`${to}/`)
}

function groupHasActiveChild(pathname: string, children: NavLeaf[]) {
  return children.some((child) => pathMatches(pathname, child.to))
}

const linkClass = cn(
  'rounded-lg px-3 py-2.5 text-sm text-stone-300 transition-colors hover:bg-sidebar-hover hover:text-white',
  '[&.active]:bg-amber-500/15 [&.active]:font-medium [&.active]:text-amber-300'
)

function NavLinks({
  items,
  pathname,
  onNavigate,
}: {
  items: NavEntry[]
  pathname: string
  onNavigate?: () => void
}) {
  const initiallyOpen = useMemo(() => {
    const open = new Set<string>()
    for (const entry of items) {
      if (isNavGroup(entry) && groupHasActiveChild(pathname, entry.children)) {
        open.add(entry.id)
      }
    }
    return open
  }, [items, pathname])

  const [openGroups, setOpenGroups] = useState<Set<string>>(initiallyOpen)

  useEffect(() => {
    setOpenGroups((prev) => {
      const next = new Set(prev)
      for (const id of initiallyOpen) next.add(id)
      return next
    })
  }, [initiallyOpen])

  function toggleGroup(id: string) {
    setOpenGroups((prev) => {
      const next = new Set(prev)
      if (next.has(id)) next.delete(id)
      else next.add(id)
      return next
    })
  }

  return (
    <nav className="flex flex-col gap-1">
      {items.map((entry) => {
        if (!isNavGroup(entry)) {
          const Icon = entry.icon
          return (
            <Link
              key={entry.to}
              to={entry.to}
              onClick={onNavigate}
              activeOptions={{ exact: entry.to === '/' }}
              className={linkClass}
            >
              <span className="flex items-center gap-2.5">
                <Icon className="size-4 shrink-0 opacity-80" />
                {entry.label}
              </span>
            </Link>
          )
        }

        const GroupIcon = entry.icon
        const isOpen = openGroups.has(entry.id)
        const childActive = groupHasActiveChild(pathname, entry.children)

        return (
          <div key={entry.id} className="flex flex-col gap-0.5">
            <button
              type="button"
              onClick={() => toggleGroup(entry.id)}
              aria-expanded={isOpen}
              className={cn(
                'flex w-full items-center gap-2.5 rounded-lg px-3 py-2.5 text-left text-sm transition-colors hover:bg-sidebar-hover hover:text-white',
                childActive ? 'font-medium text-amber-200' : 'text-stone-300'
              )}
            >
              <GroupIcon className="size-4 shrink-0 opacity-80" />
              <span className="min-w-0 flex-1 truncate">{entry.label}</span>
              <ChevronDown
                className={cn(
                  'size-4 shrink-0 opacity-60 transition-transform',
                  isOpen && 'rotate-180'
                )}
              />
            </button>
            {isOpen ? (
              <div className="ml-3 flex flex-col gap-0.5 border-l border-sidebar-border pl-2">
                {entry.children.map((child) => {
                  const ChildIcon = child.icon
                  return (
                    <Link
                      key={child.to}
                      to={child.to}
                      onClick={onNavigate}
                      activeOptions={{ exact: true }}
                      className={cn(linkClass, 'py-2')}
                    >
                      <span className="flex items-center gap-2.5">
                        <ChildIcon className="size-3.5 shrink-0 opacity-80" />
                        {child.label}
                      </span>
                    </Link>
                  )
                })}
              </div>
            ) : null}
          </div>
        )
      })}
    </nav>
  )
}

export function AdminLayout() {
  const router = useRouter()
  const pathname = useRouterState({ select: (s) => s.location.pathname })
  const { role } = useRouteContext({ from: '/_admin' })
  const [mobileNavOpen, setMobileNavOpen] = useState(false)

  const visibleNav = useMemo(
    () => filterNav(nav, isAdminRole(role)),
    [role]
  )

  useEffect(() => {
    setMobileNavOpen(false)
  }, [pathname])

  async function signOut() {
    await supabase.auth.signOut()
    await router.navigate({ to: '/login' })
  }

  return (
    <div className="flex h-dvh overflow-hidden">
      <header className="fixed inset-x-0 top-0 z-40 flex h-14 items-center justify-between border-b border-sidebar-border bg-sidebar px-4 safe-top lg:hidden">
        <button
          type="button"
          onClick={() => setMobileNavOpen(true)}
          className="flex size-10 items-center justify-center rounded-lg text-stone-200 hover:bg-sidebar-hover"
          aria-label="Open navigation menu"
        >
          <Menu className="size-5" />
        </button>
        <div className="min-w-0 flex-1 px-3 text-center">
          <p className="truncate text-[10px] tracking-widest text-amber-400 uppercase">Donate Quran</p>
          <p className="truncate text-sm font-semibold text-white">Portal</p>
        </div>
        <div className="size-10" aria-hidden />
      </header>

      <Sheet open={mobileNavOpen} onOpenChange={setMobileNavOpen}>
        <SheetContent
          side="left"
          className="nav-sheet w-[min(100vw-3rem,18rem)] max-w-[85vw] border-sidebar-border bg-sidebar p-4 pt-6 text-stone-200 sm:max-w-xs"
        >
          <SheetHeader className="mb-6 px-3 text-left">
            <SheetDescription className="text-xs font-semibold tracking-widest text-amber-400 uppercase">
              Donate Quran
            </SheetDescription>
            <SheetTitle className="text-white">Portal</SheetTitle>
            <div className="mt-3 h-1 w-full overflow-hidden rounded-full bg-sidebar-border" aria-hidden>
              <div className="h-full w-3/5 rounded-full bg-amber-400" />
            </div>
          </SheetHeader>
          <div className="sidebar-scroll min-h-0 overflow-y-auto">
            <NavLinks
              items={visibleNav}
              pathname={pathname}
              onNavigate={() => setMobileNavOpen(false)}
            />
          </div>
          <Button
            type="button"
            variant="destructive"
            className="mt-8 w-full justify-start"
            onClick={() => void signOut()}
          >
            <LogOut className="size-4" />
            Sign out
          </Button>
        </SheetContent>
      </Sheet>

      <aside className="hidden h-dvh w-60 shrink-0 flex-col border-r border-sidebar-border bg-sidebar p-4 text-stone-200 lg:flex">
        <div className="mb-6 px-3">
          <p className="text-xs font-semibold tracking-widest text-amber-400 uppercase">Donate Quran</p>
          <h1 className="text-lg font-bold text-white">Portal</h1>
          <div className="mt-3 h-1 w-full overflow-hidden rounded-full bg-sidebar-border" aria-hidden>
            <div className="h-full w-3/5 rounded-full bg-amber-400" />
          </div>
        </div>
        <div className="sidebar-scroll min-h-0 flex-1">
          <NavLinks items={visibleNav} pathname={pathname} />
        </div>
        <Button
          type="button"
          variant="destructive"
          className="mt-4 w-full shrink-0 justify-start"
          onClick={() => void signOut()}
        >
          <LogOut className="size-4" />
          Sign out
        </Button>
      </aside>

      <main className="min-h-0 min-w-0 flex-1 overflow-x-hidden overflow-y-auto bg-cream px-4 pt-[calc(3.5rem+env(safe-area-inset-top))] pb-[max(1rem,env(safe-area-inset-bottom))] sm:px-6 lg:px-8 lg:pt-8 lg:pb-8">
        <div className="w-full">
          <Outlet />
        </div>
      </main>
    </div>
  )
}
