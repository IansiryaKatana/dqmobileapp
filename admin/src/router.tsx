import {
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  redirect,
} from '@tanstack/react-router'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { toast } from 'sonner'
import { requireStaff, isAdminRole } from './lib/supabase'
import type { StaffRole } from './lib/types'
import { AdminLayout } from './components/AdminLayout'
import { LoginPage } from './routes/LoginPage'
import { DashboardPage } from './routes/DashboardPage'
import { ContentPage } from './routes/ContentPage'
import { FaqPage } from './routes/FaqPage'
import { TopicsPage } from './routes/TopicsPage'
import { DonationsPage } from './routes/DonationsPage'
import { OrdersPage } from './routes/OrdersPage'
import { ScholarPage } from './routes/ScholarPage'
import { SettingsPage } from './routes/SettingsPage'
import { RevenueCatPage } from './routes/RevenueCatPage'
import { NavigationPage } from './routes/NavigationPage'
import { GuidesPage } from './routes/GuidesPage'
import { UsersPage } from './routes/UsersPage'
import { NotificationsPage } from './routes/NotificationsPage'
import { AppMediaPage } from './routes/AppMediaPage'

const queryClient = new QueryClient({
  defaultOptions: { queries: { staleTime: 30_000, retry: 1 } },
})

function requireAdminRole(role: StaffRole | null) {
  if (!isAdminRole(role)) {
    toast.error('Admin access required')
    throw redirect({ to: '/' })
  }
}

const rootRoute = createRootRoute({
  component: () => (
    <QueryClientProvider client={queryClient}>
      <Outlet />
    </QueryClientProvider>
  ),
})

const loginRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/login',
  component: LoginPage,
})

const adminRoute = createRoute({
  getParentRoute: () => rootRoute,
  id: '_admin',
  beforeLoad: async () => {
    const { session, role } = await requireStaff()
    if (!session || !role) throw redirect({ to: '/login' })
    return { role, session }
  },
  component: AdminLayout,
})

const dashboardRoute = createRoute({
  getParentRoute: () => adminRoute,
  path: '/',
  component: DashboardPage,
})

const contentRoute = createRoute({
  getParentRoute: () => adminRoute,
  path: '/content',
  component: ContentPage,
})

const faqRoute = createRoute({
  getParentRoute: () => adminRoute,
  path: '/faq',
  component: FaqPage,
})

const topicsRoute = createRoute({
  getParentRoute: () => adminRoute,
  path: '/topics',
  component: TopicsPage,
})

const donationsRoute = createRoute({
  getParentRoute: () => adminRoute,
  path: '/donations',
  component: DonationsPage,
})

const ordersRoute = createRoute({
  getParentRoute: () => adminRoute,
  path: '/orders',
  validateSearch: (search: Record<string, unknown>) => ({
    status: typeof search.status === 'string' ? search.status : undefined,
  }),
  component: OrdersPage,
})

const scholarRoute = createRoute({
  getParentRoute: () => adminRoute,
  path: '/scholar',
  validateSearch: (search: Record<string, unknown>) => ({
    status: typeof search.status === 'string' ? search.status : undefined,
  }),
  component: ScholarPage,
})

const usersRoute = createRoute({
  getParentRoute: () => adminRoute,
  path: '/users',
  beforeLoad: ({ context }) => {
    requireAdminRole(context.role)
  },
  component: UsersPage,
})

const settingsRoute = createRoute({
  getParentRoute: () => adminRoute,
  path: '/settings',
  beforeLoad: ({ context }) => {
    requireAdminRole(context.role)
  },
  component: SettingsPage,
})

const revenueCatRoute = createRoute({
  getParentRoute: () => adminRoute,
  path: '/settings/revenuecat',
  beforeLoad: ({ context }) => {
    requireAdminRole(context.role)
  },
  component: RevenueCatPage,
})

const navigationRoute = createRoute({
  getParentRoute: () => adminRoute,
  path: '/navigation',
  component: NavigationPage,
})

const guidesRoute = createRoute({
  getParentRoute: () => adminRoute,
  path: '/guides',
  component: GuidesPage,
})

const appMediaRoute = createRoute({
  getParentRoute: () => adminRoute,
  path: '/app-media',
  component: AppMediaPage,
})

const notificationsRoute = createRoute({
  getParentRoute: () => adminRoute,
  path: '/notifications',
  beforeLoad: ({ context }) => {
    requireAdminRole(context.role)
  },
  component: NotificationsPage,
})

const routeTree = rootRoute.addChildren([
  loginRoute,
  adminRoute.addChildren([
    dashboardRoute,
    contentRoute,
    faqRoute,
    topicsRoute,
    donationsRoute,
    ordersRoute,
    scholarRoute,
    usersRoute,
    settingsRoute,
    revenueCatRoute,
    notificationsRoute,
    navigationRoute,
    guidesRoute,
    appMediaRoute,
  ]),
])

export const router = createRouter({ routeTree })

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}
