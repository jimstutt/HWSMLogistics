// ~/Dev/NGOL-D/App/src/router/index.js
// Spec: "Ensure that localhost:5173 always loads a modal Login.vue form first"
import { createRouter, createWebHistory } from 'vue-router';
import Login from '../views/Login.vue';

const routes = [
  { path: '/', component: Login, meta: { modal: true } }, // ← enforced first
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
