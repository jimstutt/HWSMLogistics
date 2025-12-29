// ~/Dev/NGOL-D/App/src/router/index.js
// NGOLTechSpec.md: "Ensure that localhost:5173 always loads a modal Login.vue form first"
import { createRouter, createWebHistory } from 'vue-router';
import Login from '../views/Login.vue';
import Dashboard from '../views/Dashboard.vue';

const routes = [
  { path: '/', component: Login, meta: { modal: true } }, // ← Login.vue first
  { path: '/dashboard', component: Dashboard, meta: { requiresAuth: true } },
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

// Enforce login first (spec-compliant)
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token');
  if (to.meta.requiresAuth && !token) {
    next('/');
  } else if (to.path === '/' && token) {
    next('/dashboard');
  } else {
    next();
  }
});

export default router;
