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
  { path: '/calendar', name: 'calendar', component: CalendarView }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export { router }
export default router
