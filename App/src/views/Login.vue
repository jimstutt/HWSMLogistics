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
