import { createRouter, createWebHistory } from 'vue-router'
import About from '@/components/About.vue'
import Contact from '@/components/Contact.vue'
import PropertiesList from '@/components/PropertiesList.vue'
import PropertyShow from '@/components/PropertyShow.vue'
import PropertyForm from '@/components/PropertyForm.vue'
import SignIn from '@/components/users/SignIn.vue'
import SignUp from '@/components/users/SignUp.vue'
import EditProfile from '@/components/users/EditProfile.vue'
import ChangePassword from '@/components/users/ChangePassword.vue'
import ForgotPassword from '@/components/users/ForgotPassword.vue'
import ResetPassword from '@/components/users/ResetPassword.vue'
import SetPassword from '@/components/users/SetPassword.vue'
import CalendarView from '@/components/CalendarView.vue'
import Privacy from '@/components/Privacy.vue'
import Terms from '@/components/Terms.vue'
import UsersAdmin from '@/components/admin/UsersAdmin.vue'

// novos components de cadastros
import AdminReportsProperties from '@/components/admin/ReportsProperties.vue'
import AdminReportsUsers from '@/components/admin/ReportsUsers.vue'
import AdminReportsSales from '@/components/admin/ReportsSales.vue'
import AdminReportsCommissions from '@/components/admin/ReportsCommissions.vue'
import AdminReportsVisits from '@/components/admin/ReportsVisits.vue'
import AdminReportsPeople from '@/components/admin/ReportsPeople.vue'
import AdminSalesList from '@/components/admin/SalesList.vue'
import InternalDashboard from '@/components/InternalDashboard.vue'
import KanbanBoard from '@/components/kanban/KanbanBoard.vue'

const routes = [
  { path: '/', name: 'home', component: PropertiesList },
  { path: '/about', name: 'about', component: About },
  { path: '/contact', name: 'contact', component: Contact },
  { path: '/properties/new', name: 'properties-new', component: PropertyForm },
  { path: '/properties/:id', name: 'properties-show', component: PropertyShow, props: true },
  { path: '/properties/:id/edit', name: 'properties-edit', component: PropertyForm, props: true },
  { path: '/users/sign_in', name: 'sign-in', component: SignIn, props: true },
  { path: '/users/sign_up', name: 'sign-up', component: SignUp, props: true },
  { path: '/users/edit', name: 'user-edit', component: EditProfile },
  { path: '/users/password/change', name: 'user-password-change', component: ChangePassword },
  { path: '/users/password/new', name: 'forgot-password', component: ForgotPassword },
  { path: '/users/password/edit', name: 'reset-password', component: ResetPassword },
  { path: '/users/password/set', name: 'set-password', component: SetPassword },
  { path: '/calendar', name: 'calendar', component: CalendarView },
  { path: '/privacy', name: 'privacy', component: Privacy },
  { path: '/terms', name: 'terms', component: Terms },

  // Internal environment (privileged users)
  { path: '/internal', name: 'internal', component: InternalDashboard, meta: { requiresPrivileged: true } },

  // Kanban (usuários privilegiados)
  { path: '/kanban', name: 'kanban-board', component: KanbanBoard, meta: { requiresPrivileged: true } },

  // Admin cadastros (visíveis apenas a admins)
  { path: '/admin/reports/properties', name: 'admin-reports-imoveis', component: AdminReportsProperties, meta: { requiresAdmin: true } },
  { path: '/admin/reports/users', name: 'admin-reports-usuarios', component: AdminReportsUsers, meta: { requiresAdmin: true } },
  { path: '/admin/reports/sales', name: 'admin-reports-vendas', component: AdminReportsSales, meta: { requiresAdmin: true } },
  { path: '/admin/reports/commissions', name: 'admin-reports-comissoes', component: AdminReportsCommissions, meta: { requiresAdmin: true } },
  { path: '/admin/reports/visits', name: 'admin-reports-visitas', component: AdminReportsVisits, meta: { requiresAdmin: true } },
  { path: '/admin/cadastros/people', name: 'admin-reports-people', component: AdminReportsPeople, meta: { requiresAdmin: true } },
  { path: '/admin/:id/sales', name: 'sales-list', component: AdminSalesList, props: true, meta: { requiresAdmin: true } },

  // Admin users
  { path: '/admin/users', name: 'admin-users', component: UsersAdmin }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// Navigation guard para verificar autenticação e permissões
router.beforeEach(async (to, from, next) => {
  const requiresAuth = to.matched.some(record => record.meta.requiresPrivileged || record.meta.requiresAdmin)
  
  if (requiresAuth) {
    try {
      const response = await fetch('/current_user', { credentials: 'same-origin' })
      
      if (!response.ok) {
        // Usuário não autenticado
        next({ name: 'sign-in', query: { redirect: to.fullPath } })
        return
      }
      
      const user = await response.json()
      
      if (!user || !user.id) {
        // Sem usuário logado
        next({ name: 'sign-in', query: { redirect: to.fullPath } })
        return
      }
      
      // Verifica se é buyer (role 0) - não tem acesso às áreas internas
      if (user.role === 0 || user.role === 'buyer') {
        next({ name: 'home' })
        return
      }
      
      // Verifica se a rota requer admin
      if (to.meta.requiresAdmin) {
        if (user.role !== 2 && user.role !== 'admin') {
          next({ name: 'home' })
          return
        }
      }
      
      // Verifica se a rota requer privilegiado (agent ou admin)
      if (to.meta.requiresPrivileged) {
        if (user.role !== 1 && user.role !== 'agent' && user.role !== 2 && user.role !== 'admin') {
          next({ name: 'home' })
          return
        }
      }
      
      next()
    } catch (error) {
      console.error('Erro ao verificar autenticação:', error)
      next({ name: 'sign-in', query: { redirect: to.fullPath } })
    }
  } else {
    next()
  }
})

export { router }
export default router
