import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login.vue'
import Dashboard from '../views/Dashboard.vue'

const routes = [
  { path: '/', name: 'Login', component: Login, meta: { requiresAuth: false } },
  { path: '/dashboard', name: 'Dashboard', component: Dashboard, meta: { requiresAuth: true } }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('ngol_token')
  if (to.meta.requiresAuth && !token) next('/')
  else if (to.path === '/' && token) next('/dashboard')
  else next()
})

export default router
