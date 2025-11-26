<template>
  <div class="d-flex justify-content-center align-items-center py-5">
    <div class="card shadow-sm" style="max-width:420px; width:100%;">
      <div class="card-body">
        <h5 class="card-title mb-3">Redefinir senha</h5>
        <p class="text-muted small mb-4">Digite sua nova senha.</p>

        <div v-if="successMessage" class="alert alert-success" role="alert" data-autoclose="false">
          {{ successMessage }}
        </div>

        <div v-if="errorMessage" class="alert alert-danger" role="alert" data-autoclose="false">
          {{ errorMessage }}
        </div>

        <form @submit.prevent="handleSubmit" v-if="!successMessage">
          <div class="mb-3">
            <label class="form-label">Nova senha</label>
            <input 
              v-model="password" 
              type="password" 
              class="form-control" 
              required 
              minlength="6"
              :disabled="loading"
            />
            <small class="text-muted">Mínimo de 6 caracteres</small>
          </div>

          <div class="mb-3">
            <label class="form-label">Confirme a nova senha</label>
            <input 
              v-model="passwordConfirmation" 
              type="password" 
              class="form-control" 
              required 
              minlength="6"
              :disabled="loading"
            />
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
                Salvando...
              </span>
              <span v-else>Redefinir senha</span>
            </button>
          </div>
        </form>

        <hr />

        <div class="text-center small">
          <router-link to="/users/sign_in">Voltar para login</router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()
const password = ref('')
const passwordConfirmation = ref('')
const loading = ref(false)
const successMessage = ref('')
const errorMessage = ref('')
const resetPasswordToken = ref('')

onMounted(() => {
  resetPasswordToken.value = route.query.reset_password_token || ''
  if (!resetPasswordToken.value) {
    errorMessage.value = 'Token de redefinição inválido ou ausente.'
  }
})

const handleSubmit = async () => {
  if (password.value !== passwordConfirmation.value) {
    errorMessage.value = 'As senhas não coincidem.'
    return
  }

  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
    
    const response = await fetch('/users/password', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        user: {
          reset_password_token: resetPasswordToken.value,
          password: password.value,
          password_confirmation: passwordConfirmation.value
        }
      })
    })

    const data = await response.json()

    if (response.ok) {
      successMessage.value = 'Senha redefinida com sucesso! Redirecionando...'
      setTimeout(() => {
        window.location.href = '/'
      }, 2000)
    } else {
      errorMessage.value = data.error || 'Erro ao redefinir senha. Token pode estar expirado.'
    }
  } catch (error) {
    console.error('Error:', error)
    errorMessage.value = 'Erro ao redefinir senha. Tente novamente.'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.card-title { 
  color:#1A2E66; 
  font-weight:700; 
}

.btn-primary { 
  color:#fff; 
}

@media (max-width: 576px) {
  .card { 
    margin: 0 1rem; 
  }
}
</style>
