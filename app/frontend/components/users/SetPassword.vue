<template>
  <div class="d-flex justify-content-center py-5">
    <div class="card shadow-sm" style="max-width:520px; width:100%;">
      <div class="card-body">
        <h5 class="card-title mb-3">Definir senha</h5>
        <p class="text-muted small mb-3">
          Defina uma senha para sua conta para também poder entrar com e‑mail e senha.
        </p>

        <form @submit.prevent="onSubmit">
          <div class="mb-3">
            <label class="form-label">Nova senha</label>
            <input v-model="password" type="password" class="form-control" minlength="6" required />
            <div class="form-text small">Mínimo 6 caracteres.</div>
          </div>

          <div class="mb-3">
            <label class="form-label">Confirme a nova senha</label>
            <input v-model="passwordConfirmation" type="password" class="form-control" minlength="6" required />
            <div v-if="mismatch" class="text-danger small mt-1">As senhas não coincidem.</div>
          </div>

          <div v-if="error" class="alert alert-danger small" data-autoclose="false">{{ error }}</div>
          <div v-if="success" class="alert alert-success small" data-autoclose="false">{{ success }}</div>

          <div class="d-grid">
            <button class="btn" :disabled="loading || mismatch" style="background:#1A2E66; color:#fff;">
              <span v-if="loading">Salvando...</span>
              <span v-else>Salvar senha</span>
            </button>
          </div>
        </form>

        <hr />
        <div class="text-center small">
          <router-link to="/">Voltar</router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const csrf = ref(document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '')
const password = ref('')
const passwordConfirmation = ref('')
const loading = ref(false)
const error = ref('')
const success = ref('')

const mismatch = computed(() => password.value && passwordConfirmation.value && password.value !== passwordConfirmation.value)

const onSubmit = async () => {
  error.value = ''
  success.value = ''
  if (mismatch.value) return
  loading.value = true
  try {
    const res = await fetch('/users/password/set', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf.value,
        'Accept': 'application/json'
      },
      credentials: 'same-origin',
      body: JSON.stringify({ user: { password: password.value, password_confirmation: passwordConfirmation.value } })
    })
    if (res.ok) {
      const data = await res.json().catch(() => ({}))
      success.value = data.message || 'Senha definida com sucesso.'
      // Recarrega o estado do usuário antes de redirecionar
      try {
        await fetch('/current_user.json', { credentials: 'same-origin' })
      } catch (e) {}
      setTimeout(() => router.push('/'), 800)
    } else {
      const data = await res.json().catch(() => null)
      error.value = (data && data.error) || 'Falha ao definir senha.'
    }
  } catch (e) {
    error.value = 'Erro ao definir senha.'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.card-title { color:#1A2E66; font-weight:700; }
@media (max-width: 576px) { .card { margin: 0 1rem; } }
</style>
