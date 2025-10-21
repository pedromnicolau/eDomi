import { createRouter, createWebHistory } from 'vue-router'
import About from '@/components/About.vue'
import PropertiesList from '@/components/PropertiesList.vue'

const routes = [
  { path: '/', name: 'home', component: PropertiesList },
  { path: '/about', name: 'about', component: About },
]

export const router = createRouter({
  history: createWebHistory(),
  routes,
})
