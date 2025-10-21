import { createRouter, createWebHistory } from 'vue-router'
import HelloWorld from '@/components/HelloWorld.vue'

const routes = [
  { path: '/', name: 'home', component: HelloWorld },
]

export const router = createRouter({
  history: createWebHistory(),
  routes,
})
