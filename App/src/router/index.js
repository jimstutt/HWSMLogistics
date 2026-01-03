// ~/Dev/NGOL-D/App/src/router/index.js
// Spec: "Ensure that localhost:5173 always loads a modal Login.vue form first"
import { createRouter, createWebHistory } from 'vue-router';
import Login from '../views/Login.vue';
import Dashboard from '../views/Dashboard.vue';

const routes = [
  { path: '/', component: Login, name: 'Login' },
  { path: '/dashboard', component: Dashboard, name: 'Dashboard' },
  // Redirect all unknown routes to Login
  { path: '/:pathMatch(.*)*', redirect: '/' }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
