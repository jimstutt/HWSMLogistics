#!/bin/bash
set -e

echo "🚀 Creating NGOL-D implementation script..."

cat > implement-ngol.sh << 'SCRIPT'
#!/bin/bash
set -e

echo "🚀 NGOL-D Implementation Script"
cd ~/Dev/NGOL-D/App

# Step 1: Create .env file
echo "🔧 Step 1: Creating .env file"
cat > .env << 'ENV'
VITE_API_BASE_URL=http://localhost:5000/api
VITE_GOOGLE_MAPS_API_KEY=AIzaSyBTmKzNwMM1OIruKtneSGHYUYbJHMUL6j0
VITE_DEFAULT_ADMIN_EMAIL=ngologisticsadmin@ngologistics.org
ENV

# Step 2: Update main.js
echo "🔧 Step 2: Updating main.js"
mkdir -p src
cat > src/main.js << 'JS'
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)

router.isReady().then(() => {
  app.mount('#app')
})
JS

# Step 3: Create router
echo "🔧 Step 3: Creating router"
mkdir -p src/router
cat > src/router/index.js << 'ROUTER'
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
ROUTER

# Step 4: Create views directory
echo "🔧 Step 4: Creating views directory"
mkdir -p src/views

# Step 5: Create Login.vue
echo "🔧 Step 5: Creating Login.vue"
cat > src/views/Login.vue << 'LOGIN'
<template>
  <div class="login-container">
    <div class="login-modal">
      <div class="logo">
        <h1>NGO Logistics</h1>
        <p>Dashboard</p>
      </div>
      <form @submit.prevent="handleSubmit" class="login-form" novalidate>
        <div class="form-group">
          <label for="email">Email Address</label>
          <input
            id="email"
            v-model="email"
            type="email"
            class="form-control"
            value="ngologisticsadmin@ngologistics.org"
          />
        </div>
        <div class="form-group">
          <label for="password">Password</label>
          <input
            id="password"
            v-model="password"
            type="password"
            class="form-control"
          />
        </div>
        <button type="submit" class="btn btn-primary">
          Login
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const email = ref('ngologisticsadmin@ngologistics.org')
const password = ref('')

const handleSubmit = () => {
  localStorage.setItem('ngol_token', 'mock_token')
  router.push('/dashboard')
}
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.login-modal {
  background: white;
  border-radius: 15px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.2);
  width: 100%;
  max-width: 450px;
  overflow: hidden;
}

.logo {
  text-align: center;
  padding: 30px 20px;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
}

.logo h1 {
  margin: 0;
  font-size: 2.2rem;
  font-weight: 700;
}

.logo p {
  margin: 5px 0 0 0;
  font-size: 1.2rem;
  opacity: 0.9;
}

.login-form {
  padding: 30px;
}

.form-group {
  margin-bottom: 20px;
}

label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #333;
}

.form-control {
  width: 100%;
  padding: 12px 15px;
  border: 2px solid #ddd;
  border-radius: 8px;
  font-size: 1rem;
}

.btn-primary {
  width: 100%;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
  border: none;
  padding: 14px;
  border-radius: 8px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
}
</style>
LOGIN

# Step 6: Create Dashboard.vue
echo "🔧 Step 6: Creating Dashboard.vue"
cat > src/views/Dashboard.vue << 'DASHBOARD'
<template>
  <div class="dashboard-container">
    <h1>Welcome to NGO Logistics Dashboard</h1>
    <p>This is the dashboard page.</p>
  </div>
</template>

<style scoped>
.dashboard-container {
  padding: 20px;
}
</style>
DASHBOARD

# Step 7: Create App.vue
echo "🔧 Step 7: Creating App.vue"
cat > src/App.vue << 'APP'
<template>
  <router-view />
</template>
APP

# Step 8: Install dependencies
echo "🔧 Step 8: Installing dependencies"
npm install chart.js

# Step 9: Rebuild
echo "🔧 Step 9: Rebuilding application"
npm run build

# Step 10: Deploy
echo "🚀 Step 10: Deploying application"
cd ~/Dev/NGOL-D
./deploy-prod.sh

echo "✅ NGOL-D implementation completed successfully!"
echo "💡 Access the application at: http://localhost"
SCRIPT

chmod +x implement-ngol.sh
echo "✅ Script created successfully"
echo "💡 Run './implement-ngol.sh' to implement NGOL-D"
