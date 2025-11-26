<template>
  <div class="d-flex justify-content-center align-items-center py-5">
    <div class="card shadow-sm" style="max-width:420px; width:100%;">
      <div class="card-body">
        <h5 class="card-title mb-3">Esqueceu sua senha?</h5>
        <p class="text-muted small mb-4">Informe o e-mail cadastrado. Enviaremos um link para redefinir sua senha.</p>

        <div v-if="successMessage" class="alert alert-success" role="alert" data-autoclose="false">
          {{ successMessage }}
        </div>

        <div v-if="errorMessage" class="alert alert-danger" role="alert" data-autoclose="false">
          {{ errorMessage }}
        </div>

        <form @submit.prevent="handleSubmit" v-if="!successMessage">
          <div class="mb-3">
            <label class="form-label">E-mail</label>
            <input 
              v-model="email" 
              type="email" 
              class="form-control" 
              required 
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
                Enviando...
              </span>
              <span v-else>Enviar email</span>
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
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const email = ref('')
const loading = ref(false)
const successMessage = ref('')
const errorMessage = ref('')

const handleSubmit = async () => {
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
    
    const response = await fetch('/users/password', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        user: {
          email: email.value
        }
      })
    })

    const data = await response.json()

    if (response.ok) {
      successMessage.value = 'Email enviado com sucesso! Verifique sua caixa de entrada.'
      setTimeout(() => {
        router.push('/users/sign_in')
      }, 3000)
    } else {
      errorMessage.value = data.error || 'Erro ao enviar email. Verifique o endereço informado.'
    }
  } catch (error) {
    console.error('Error:', error)
    errorMessage.value = 'Erro ao enviar email. Tente novamente.'
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
