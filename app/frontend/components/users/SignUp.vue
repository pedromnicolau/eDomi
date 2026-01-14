<template>
  <div class="d-flex justify-content-center align-items-center py-5">
    <div class="card shadow-sm" style="max-width:520px; width:100%;">
      <div class="card-body">
        <h5 class="card-title mb-3">Criar conta</h5>

        <form ref="form" @submit.prevent="onSubmit" action="/users" method="post" class="needs-validation" novalidate>
          <input type="hidden" name="authenticity_token" :value="csrf" />

          <div
            v-if="error"
            class="alert alert-danger"
            role="alert"
            :data-autoclose="noAutoClose"
          >{{ error }}</div>

          <div class="mb-3">
            <label class="form-label">Nome</label>
            <input name="user[name]" v-model="name" type="text" class="form-control" required />
          </div>

          <div class="mb-3">
            <label class="form-label">E‑mail</label>
            <input name="user[email]" v-model="email" type="email" class="form-control" required />
          </div>

          <div class="mb-3">
            <label class="form-label">Senha</label>
            <input name="user[password]" v-model="password" type="password" class="form-control" required minlength="6" />
            <div class="form-text small">Mínimo 6 caracteres.</div>
          </div>

          <div class="mb-3">
            <label class="form-label">Confirme a senha</label>
            <input name="user[password_confirmation]" v-model="passwordConfirmation" type="password" class="form-control" required minlength="6" />
            <div v-if="mismatch" class="text-danger small mt-1">As senhas não coincidem.</div>
          </div>

          <div class="d-grid">
            <button type="submit" class="btn" :disabled="!isValid || submitting" style="background:#1A2E66; color:#fff; border-color:#1A2E66;">
              <span v-if="submitting">Enviando...</span>
              <span v-else>Criar conta</span>
            </button>
          </div>
        </form>

        <hr />

        <div class="text-center my-3">
          <span class="text-muted small">ou</span>
        </div>
        <div class="d-grid mb-3">
          <a :href="googleAuthUrl" class="google-btn" aria-label="Criar conta com Google">
            <span class="google-icon" aria-hidden="true">
              <svg width="18" height="18" viewBox="0 0 18 18" xmlns="http://www.w3.org/2000/svg">
                <path fill="#EA4335" d="M9 3.48c1.69 0 3.2.58 4.39 1.54l2.93-2.93C14.94.69 12.15 0 9 0 5.48 0 2.41 1.64.44 4.1l3.42 2.66C4.9 4.35 6.8 3.48 9 3.48z"/>
                <path fill="#34A853" d="M17.64 9.2c0-.64-.06-1.25-.18-1.84H9v3.48h4.84c-.21 1.14-.84 2.1-1.8 2.74l2.77 2.15c1.62-1.49 2.83-3.69 2.83-6.53z"/>
                <path fill="#FBBC05" d="M3.86 10.86A5.52 5.52 0 0 1 3.56 9c0-.64.11-1.26.3-1.86L.44 4.1A8.98 8.98 0 0 0 0 9c0 1.45.35 2.82.97 4.03l2.89-2.17z"/>
                <path fill="#4285F4" d="M9 18c2.43 0 4.47-.8 5.96-2.17l-2.77-2.15c-.77.52-1.76.83-3.19.83-2.2 0-4.1-1.47-4.77-3.45L.97 13.03C2.94 16.36 5.73 18 9 18z"/>
              </svg>
            </span>
            <span class="google-text">Criar conta com Google</span>
          </a>
        </div>

        <div class="text-center small">
          Já tem conta? <router-link to="/users/sign_in">Entrar</router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const csrf = ref(document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '')

const name = ref('')
const email = ref('')
const password = ref('')
const passwordConfirmation = ref('')

const form = ref(null)

const mismatch = computed(() => {
  return passwordConfirmation.value.length > 0 && (password.value !== passwordConfirmation.value)
})

// novo: validação mais restrita para habilitar o botão de submit:
// - name e email preenchidos
// - password e passwordConfirmation com mais de 6 caracteres (strictly > 6)
// - password === passwordConfirmation
const isValid = computed(() => {
  const hasName = String(name.value || '').trim().length > 0
  const hasEmail = String(email.value || '').trim().length > 0
  const pwLenOk = String(password.value).length >= 6
  const pwConfLenOk = String(passwordConfirmation.value).length >= 6
  const same = password.value === passwordConfirmation.value
  return hasName && hasEmail && pwLenOk && pwConfLenOk && same
})

const submitting = ref(false)
const error = ref(null)
const googleAuthUrl = '/users/auth/google_oauth2'
const router = useRouter()

// novo computed que define quando o alerta NÃO deve auto-fechar
const noAutoClose = computed(() => {
  if (!error.value) return null
  // mantém alerta aberto para email duplicado ou mensagens relacionadas a email inválido
  if (/já existe uma conta com esse email/i.test(error.value)) return 'false'
  if (/(email.*(inválido|invalido)|inválido|invalido|already been taken)/i.test(error.value)) return 'false'
  return null
})

const parseErrorMessage = async (res) => {
  // tenta extrair mensagens úteis de várias formas comuns
  try {
    const data = await res.json().catch(() => null)
    if (!data) return null
    // Devise pode retornar resource errors: { "error": "..."} or { "errors": ["..."] } or { "user": { "email": ["has already been taken"] } }
    if (data.error) return data.error

    // novo: lidar com { "errors": { "email": ["..."] } } e similares
    if (data.errors && typeof data.errors === 'object') {
      // preferência para email especificamente
      if (data.errors.email) {
        if (Array.isArray(data.errors.email)) return data.errors.email.join(', ')
        return String(data.errors.email)
      }
      // se errors for um objeto com arrays por campo, coletar todas as mensagens
      const parts = []
      for (const key in data.errors) {
        const v = data.errors[key]
        if (Array.isArray(v)) parts.push(...v)
        else if (v) parts.push(String(v))
      }
      if (parts.length) return parts.join(', ')
    }

    if (data.errors && Array.isArray(data.errors)) return data.errors.join(', ')
    if (data.errors && typeof data.errors === 'string') return data.errors
    if (data.user && data.user.email && Array.isArray(data.user.email)) return data.user.email.join(', ')
    if (data.message) return data.message
    // try to collect full_messages
    if (data.full_messages && Array.isArray(data.full_messages)) return data.full_messages.join(', ')
    return JSON.stringify(data)
  } catch (e) {
    return null
  }
}

const onSubmit = async () => {
  if (mismatch.value) return
  submitting.value = true
  error.value = null

  try {
    const payload = { user: { name: name.value, email: email.value, password: password.value, password_confirmation: passwordConfirmation.value } }
    const res = await fetch('/users', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf.value
      },
      credentials: 'same-origin',
      body: JSON.stringify(payload)
    })

    if (res.ok) {
      // registro OK: redireciona para home (mantém comportamento anterior)
      window.location.href = '/'
      return
    }

    // tratado: conflitos/validations (422) ou outros erros
    if (res.status === 422 || res.status === 400) {
      const msg = await parseErrorMessage(res)
      // mensagem amigável para email duplicado
      if (msg && /email.*taken|já existe|already been taken/i.test(msg)) {
        error.value = 'Já existe uma conta com esse email'
      } else {
        error.value = msg || 'Falha ao criar conta. Verifique os dados e tente novamente.'
      }
      // mantém o form renderizado
      submitting.value = false
      return
    }

    // fallback para outros status
    const msg = await parseErrorMessage(res)
    error.value = msg || `Erro inesperado (${res.status})`
  } catch (e) {
    error.value = 'Erro de rede. Tente novamente.'
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  const q = router.currentRoute.value.query
  if (q && q.error) {
    const msg = Array.isArray(q.error) ? q.error[0] : q.error
    error.value = String(msg)
    const url = new URL(window.location.href)
    url.searchParams.delete('error')
    window.history.replaceState({}, '', url.toString())
  }
})
</script>

<style scoped>
.card-title { color:#1A2E66; font-weight:700; }
@media (max-width: 576px) {
  .card { margin: 0 1rem; }
}
</style>

<style scoped>
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
