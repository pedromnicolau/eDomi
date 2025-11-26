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

        <div class="text-center my-3">
          <span class="text-muted small">ou</span>
        </div>

        <div class="d-grid mb-3">
          <a :href="googleAuthUrl" class="google-btn" aria-label="Entrar com Google">
            <span class="google-icon" aria-hidden="true">
              <svg width="18" height="18" viewBox="0 0 18 18" xmlns="http://www.w3.org/2000/svg">
                <path fill="#EA4335" d="M9 3.48c1.69 0 3.2.58 4.39 1.54l2.93-2.93C14.94.69 12.15 0 9 0 5.48 0 2.41 1.64.44 4.1l3.42 2.66C4.9 4.35 6.8 3.48 9 3.48z"/>
                <path fill="#34A853" d="M17.64 9.2c0-.64-.06-1.25-.18-1.84H9v3.48h4.84c-.21 1.14-.84 2.1-1.8 2.74l2.77 2.15c1.62-1.49 2.83-3.69 2.83-6.53z"/>
                <path fill="#FBBC05" d="M3.86 10.86A5.52 5.52 0 0 1 3.56 9c0-.64.11-1.26.3-1.86L.44 4.1A8.98 8.98 0 0 0 0 9c0 1.45.35 2.82.97 4.03l2.89-2.17z"/>
                <path fill="#4285F4" d="M9 18c2.43 0 4.47-.8 5.96-2.17l-2.77-2.15c-.77.52-1.76.83-3.19.83-2.2 0-4.1-1.47-4.77-3.45L.97 13.03C2.94 16.36 5.73 18 9 18z"/>
              </svg>
            </span>
            <span class="google-text">Entrar com Google</span>
          </a>
        </div>

        <hr />

        <div class="text-center small">
          Ainda não tem conta? <router-link to="/users/sign_up">Registre‑se</router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const csrf = ref(document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '')
const email = ref('')
const password = ref('')
const rememberMe = ref(false)
const loading = ref(false)
const errorMessage = ref('')
const googleAuthUrl = '/users/auth/google_oauth2'

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

onMounted(() => {
  const q = router.currentRoute.value.query
  if (q && q.error) {
    const msg = Array.isArray(q.error) ? q.error[0] : q.error
    errorMessage.value = String(msg)
    // limpa o query param sem recarregar
    const url = new URL(window.location.href)
    url.searchParams.delete('error')
    window.history.replaceState({}, '', url.toString())
  }
})
</script>

<style scoped>
.card-title { color:#1A2E66; font-weight:700; }
.btn-primary { color:#fff; }
@media (max-width: 576px) {
  .card { margin: 0 1rem; }
}

.google-btn {
  width: 100%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  height: 44px;
  padding: 0 16px;
  border: 1px solid #dadce0;
  border-radius: 4px;
  background: #fff;
  color: #3c4043;
  text-decoration: none;
  font-weight: 500;
  box-shadow: 0 1px 1px rgba(0,0,0,0.1);
  transition: background .2s ease, box-shadow .2s ease;
}
.google-btn:hover { background: #f7f8f8; box-shadow: 0 1px 2px rgba(0,0,0,0.2); }
.google-btn:active { background: #eee; }
.google-btn:focus { outline: none; box-shadow: 0 0 0 3px rgba(66,133,244,.3); }
.google-icon { width: 18px; height: 18px; display: inline-flex; }
.google-text { font-size: 14px; line-height: 1; }
</style>
