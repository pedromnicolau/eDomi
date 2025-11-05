import { createRouter, createWebHistory } from 'vue-router'
import About from '@/components/About.vue'
import Contact from '@/components/Contact.vue'
import PropertiesList from '@/components/PropertiesList.vue'
import PropertyShow from '@/components/PropertyShow.vue'
import PropertyForm from '@/components/PropertyForm.vue'
import SignIn from '@/components/users/SignIn.vue'
import SignUp from '@/components/users/SignUp.vue'
import ForgotPassword from '@/components/users/ForgotPassword.vue'
import ResetPassword from '@/components/users/ResetPassword.vue'
import EditProfile from '@/components/users/EditProfile.vue'
import ChangePassword from '@/components/users/ChangePassword.vue'
import CalendarView from '@/components/CalendarView.vue'
import Privacy from '@/components/Privacy.vue'
import Terms from '@/components/Terms.vue'
import UsersAdmin from '@/components/admin/UsersAdmin.vue'

// novos components de cadastros
import AdminRelatoriosProperties from '@/components/admin/RelatoriosProperties.vue'
import AdminRelatoriosUsers from '@/components/admin/RelatoriosUsers.vue'
import AdminRelatoriosSales from '@/components/admin/RelatoriosSales.vue'
import AdminRelatoriosCommissions from '@/components/admin/RelatoriosCommissions.vue'
import AdminRelatoriosVisits from '@/components/admin/RelatoriosVisits.vue'
import AdminCadastrosPeople from '@/components/admin/CadastrosPeople.vue'
import AdminSalesList from '@/components/admin/SalesList.vue'

const routes = [
  { path: '/', name: 'home', component: PropertiesList },
  { path: '/about', name: 'about', component: About },
  { path: '/contact', name: 'contact', component: Contact },
  { path: '/properties/new', name: 'properties-new', component: PropertyForm },
  { path: '/properties/:id', name: 'properties-show', component: PropertyShow, props: true },
  { path: '/properties/:id/edit', name: 'properties-edit', component: PropertyForm, props: true },
  { path: '/users/sign_in', name: 'sign-in', component: SignIn, props: true },
  { path: '/users/sign_up', name: 'sign-up', component: SignUp, props: true },
  { path: '/users/password/new', name: 'password-new', component: ForgotPassword },
  { path: '/users/password/edit', name: 'password-edit', component: ResetPassword },
  { path: '/users/edit', name: 'user-edit', component: EditProfile },
  { path: '/users/password/change', name: 'user-password-change', component: ChangePassword },
  { path: '/calendar', name: 'calendar', component: CalendarView },
  { path: '/privacy', name: 'privacy', component: Privacy },
  { path: '/terms', name: 'terms', component: Terms },

  // Admin cadastros (visíveis apenas a admins)
  { path: '/admin/relatorios/imoveis', name: 'admin-relatorios-imoveis', component: AdminRelatoriosProperties, meta: { requiresAdmin: true } },
  { path: '/admin/relatorios/usuarios', name: 'admin-relatorios-usuarios', component: AdminRelatoriosUsers, meta: { requiresAdmin: true } },
  { path: '/admin/relatorios/vendas', name: 'admin-relatorios-vendas', component: AdminRelatoriosSales, meta: { requiresAdmin: true } },
  { path: '/admin/relatorios/comissoes', name: 'admin-relatorios-comissoes', component: AdminRelatoriosCommissions, meta: { requiresAdmin: true } },
  { path: '/admin/relatorios/visitas', name: 'admin-relatorios-visitas', component: AdminRelatoriosVisits, meta: { requiresAdmin: true } },
  { path: '/admin/cadastros/pessoas', name: 'admin-relatorios-pessoas', component: AdminCadastrosPeople, meta: { requiresAdmin: true } },
  { path: '/admin/:id/vendas', name: 'sales-list', component: AdminSalesList, props: true, meta: { requiresAdmin: true } },

  // Admin users
  { path: '/admin/users', name: 'admin-users', component: UsersAdmin }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export { router }
export default router
