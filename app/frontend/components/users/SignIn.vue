<template>
  <div class="d-flex justify-content-center align-items-center py-5">
    <div class="card shadow-sm" style="max-width:420px; width:100%;">
      <div class="card-body">
        <h5 class="card-title mb-3">Entrar</h5>

        <div 
          v-if="errorMessage" 
          class="alert alert-danger alert-dismissible fade show" 
          role="alert"
          data-autoclose="false"
        >
          {{ errorMessage }}
          <button type="button" class="btn-close" @click="errorMessage = ''" aria-label="Close"></button>
        </div>

        <form @submit.prevent="handleSubmit">
          <div class="mb-3">
            <label class="form-label">E‑mail</label>
            <input 
              v-model="email" 
              type="email" 
              class="form-control" 
              required 
              :disabled="loading"
            />
          </div>

          <div class="mb-3">
            <label class="form-label">Senha</label>
            <input 
              v-model="password" 
              type="password" 
              class="form-control" 
              required 
              :disabled="loading"
            />
          </div>

          <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
              <input 
                v-model="rememberMe" 
                type="checkbox" 
                id="remember" 
                class="form-check-input"
              />
              <label for="remember" class="form-check-label ms-1 small">Lembrar</label>
            </div>
            <router-link to="/users/password/new" class="small">Esqueceu a senha?</router-link>
          </div>

          <div class="d-grid">
            <button 
              type="submit" 
              class="btn btn-primary" 
              style="background:#1A2E66; border-color:#1A2E66;"
              :disabled="loading"
            >
              <span v-if="loading">
                <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
                Entrando...
              </span>
              <span v-else>Entrar</span>
            </button>
          </div>
        </form>

        <hr />

        <div class="text-center small">
          Ainda não tem conta? <router-link to="/users/sign_up">Registre‑se</router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const csrf = ref(document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '')
const email = ref('')
const password = ref('')
const rememberMe = ref(false)
const loading = ref(false)
const errorMessage = ref('')

const handleSubmit = async () => {
  // Limpa erro anterior
  errorMessage.value = ''
  loading.value = true

  try {
    const response = await fetch('/users/sign_in', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf.value,
        'Accept': 'application/json'
      },
      credentials: 'same-origin',
      body: JSON.stringify({
        user: {
          email: email.value,
          password: password.value,
          remember_me: rememberMe.value ? '1' : '0'
        }
      })
    })

    const data = await response.json()

    if (response.ok) {
      // Login bem-sucedido, redireciona para home
      window.location.href = '/'
    } else {
      // Exibe mensagem de erro
      errorMessage.value = data.error || 'Email ou senha incorretos. Verifique suas credenciais e tente novamente.'
      password.value = '' // Limpa o campo de senha
    }
  } catch (error) {
    console.error('Error:', error)
    errorMessage.value = 'Erro ao tentar fazer login. Tente novamente.'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.card-title { color:#1A2E66; font-weight:700; }
.btn-primary { color:#fff; }
@media (max-width: 576px) {
  .card { margin: 0 1rem; }
}
</style>
