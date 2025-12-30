import { createApp } from 'vue'
import { createVuelidate } from '@vuelidate/core'
import App from './App.vue'
import router from './router'
import './assets/main.css'

const app = createApp(App)

// Use Vuelidate
app.use(createVuelidate())

// Use router
app.use(router)

app.mount('#app')
