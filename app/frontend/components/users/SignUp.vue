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

        <div class="text-center small">
          Já tem conta? <router-link to="/users/sign_in">Entrar</router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

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
</script>

<style scoped>
.card-title { color:#1A2E66; font-weight:700; }
@media (max-width: 576px) {
  .card { margin: 0 1rem; }
}
</style>
