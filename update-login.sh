#!/bin/bash
set -e

echo "📝 Updating Login.vue component..."
cd ./App

# Create views directory if it doesn't exist
mkdir -p src/views

cat > src/views/Login.vue << 'EOF'
<template>
  <div class="login-container">
    <div class="login-card">
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
            :class="{ 'is-invalid': submitted && !emailValid }"
            required
            autocomplete="email"
            value="ngologisticsadmin@ngologistics.org"
          />
          <div v-if="submitted && !emailValid" class="invalid-feedback">
            Please enter a valid email address
          </div>
        </div>
        
        <div class="form-group">
          <label for="password">Password</label>
          <input
            id="password"
            v-model="password"
            type="password"
            class="form-control"
            :class="{ 'is-invalid': submitted && !passwordValid }"
            required
            autocomplete="current-password"
          />
          <div v-if="submitted && !passwordValid" class="invalid-feedback">
            Password must be at least 6 characters
          </div>
          <div v-if="error" class="invalid-feedback">
            {{ error }}
          </div>
        </div>
        
        <button type="submit" class="btn btn-primary" :disabled="loading">
          <span v-if="loading">
            <i class="fas fa-spinner fa-spin"></i> Logging in...
          </span>
          <span v-else>
            Login
          </span>
        </button>
      </form>
      
      <div class="footer">
        <p>NGO Logistics Dashboard v1.0</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const email = ref('ngologisticsadmin@ngologistics.org')
const password = ref('')
const submitted = ref(false)
const loading = ref(false)
const error = ref(null)

const emailValid = ref(true)
const passwordValid = ref(true)

const validateForm = () => {
  emailValid.value = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value.trim())
  passwordValid.value = password.value.trim().length >= 6
  return emailValid.value && passwordValid.value
}

const handleSubmit = async () => {
  submitted.value = true
  
  if (!validateForm()) {
    return
  }
  
  loading.value = true
  error.value = null
  
  try {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 800))
    
    // Store user session
    localStorage.setItem('ngol_user', JSON.stringify({
      email: email.value,
      role: 'admin',
      token: 'demo_token_' + Date.now()
    }))
    
    // Redirect to dashboard
    router.push('/dashboard')
  } catch (err) {
    console.error('Login error:', err)
    error.value = 'Invalid credentials. Please try again.'
  } finally {
    loading.value = false
  }
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

.login-card {
  background: white;
  border-radius: 15px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
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
  font-size: 0.95rem;
}

.form-control {
  width: 100%;
  padding: 12px 15px;
  border: 2px solid #ddd;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.3s;
  box-sizing: border-box;
}

.form-control:focus {
  outline: none;
  border-color: #4facfe;
  box-shadow: 0 0 0 3px rgba(79, 172, 254, 0.2);
}

.form-control.is-invalid {
  border-color: #ff4d4d;
}

.invalid-feedback {
  color: #ff4d4d;
  font-size: 0.85rem;
  margin-top: 5px;
  display: block;
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
  transition: all 0.3s;
  margin-top: 10px;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(79, 172, 254, 0.4);
}

.btn-primary:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

.footer {
  text-align: center;
  padding: 20px;
  color: #666;
  font-size: 0.9rem;
  border-top: 1px solid #eee;
  background: #f9f9f9;
}

@media (max-width: 480px) {
  .login-card {
    margin: 10px;
  }
  
  .logo {
    padding: 20px 15px;
  }
  
  .login-form {
    padding: 20px;
  }
}
</style>
EOF

echo "✅ Login.vue updated successfully"
echo "💡 Next step: Rebuild the frontend with 'npm run build'"
