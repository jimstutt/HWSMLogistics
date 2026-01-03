<template>
  <div class="modal">
    <div class="card">
      <h2>Login</h2>
      <form @submit.prevent="login">
        <input v-model="email" placeholder="Email" required />
        <input v-model="password" type="password" placeholder="Password" required />
        <button type="submit">Login</button>
        <p v-if="error" class="error">{{ error }}</p>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const email = ref('admin@example.org');
const password = ref('password123');
const error = ref('');
const router = useRouter();

const login = async () => {
  try {
    const res = await fetch('http://localhost:3000/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: email.value, password: password.value })
    });

    const data = await res.json();
    if (res.ok) {
      localStorage.setItem('token', data.token);
      await router.push('/dashboard'); // ← await ensures navigation
    } else {
      error.value = data.error || 'Invalid credentials';
    }
  } catch (err) {
    error.value = 'Network error';
    console.error('Login failed:', err);
  }
};
</script>

<style scoped>
.modal { position: fixed; inset: 0; background: rgba(0,0,0,0.5); display: grid; place-items: center; }
.card { background: white; padding: 2rem; border-radius: 8px; width: 300px; }
.card input { width: 100%; padding: 0.5rem; margin: 0.5rem 0; }
.card button { width: 100%; padding: 0.5rem; background: #007bff; color: white; border: none; }
.error { color: red; text-align: center; }
</style>
