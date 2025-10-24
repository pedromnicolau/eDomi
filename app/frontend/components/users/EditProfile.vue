<template>
  <div class="d-flex justify-content-center py-5">
    <div class="card shadow-sm" style="max-width:560px; width:100%;">
      <div class="card-body">
        <h5 class="card-title mb-3">Editar perfil</h5>

        <form @submit.prevent="submitForm" class="needs-validation" novalidate>
          <div class="mb-3">
            <label class="form-label">Nome</label>
            <input name="user[name]" v-model="name" type="text" class="form-control" required />
          </div>

          <div class="mb-3">
            <label class="form-label">E‑mail</label>
            <input name="user[email]" v-model="email" type="email" class="form-control" required />
          </div>

          <hr class="my-4">

          <div class="mb-3">
            <label class="form-label">Nova senha</label>
            <input name="user[password]" v-model="newPassword" type="password" class="form-control" minlength="6" />
            <div class="form-text small">Deixe em branco se não quiser alterar a senha. Mínimo 6 caracteres.</div>
          </div>

          <div class="mb-3">
            <label class="form-label">Confirme a nova senha</label>
            <input name="user[password_confirmation]" v-model="newPasswordConfirmation" type="password" class="form-control" minlength="6" />
            <div v-if="mismatch" class="text-danger small mt-1">As senhas não coincidem.</div>
          </div>

          <hr class="my-4">

          <div class="mb-3">
            <label class="form-label">Senha atual (confirmação)</label>
            <input name="user[current_password]" v-model="currentPassword" type="password" class="form-control" required />
            <div class="form-text small">Informe a senha atual para confirmar alterações.</div>
          </div>

          <div class="d-grid mb-2">
            <button type="submit" class="btn" :disabled="mismatch" style="background:#1A2E66; color:#fff;">Salvar alterações</button>
          </div>

          <div v-if="formError" class="text-danger small mb-2">{{ formError }}</div>
          <div v-if="formSuccess" class="text-success small mb-2">{{ formSuccess }}</div>
        </form>

        <hr/>
        <div class="text-center small">
          <a href="/">Cancelar</a>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'

const csrf = ref(document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '')
const name = ref('')
const email = ref('')
const currentPassword = ref('')
const user = ref(null)

// novos campos de senha
const newPassword = ref('')
const newPasswordConfirmation = ref('')

const mismatch = computed(() =>
  newPassword.value.length > 0 && newPasswordConfirmation.value.length > 0 && (newPassword.value !== newPasswordConfirmation.value)
)

const formError = ref('')
const formSuccess = ref('')

// busca usuário atual
onMounted(async () => {
  try {
    const res = await fetch('/current_user', { credentials: 'same-origin' })
    if (res.ok) {
      const data = await res.json()
      if (data) {
        name.value = data.name || ''
        email.value = data.email || ''
      }
    }
  } catch (e) {
    // ignore
  }
})

// envio via fetch/AJAX
const submitForm = async () => {
  formError.value = ''
  formSuccess.value = ''

  if (!currentPassword.value) {
    formError.value = 'Informe sua senha atual para confirmar alterações.'
    return
  }

  // validações de senha nova (se fornecida)
  if (newPassword.value && newPassword.value.length < 6) {
    formError.value = 'A nova senha deve ter no mínimo 6 caracteres.'
    return
  }

  if (mismatch.value) {
    formError.value = 'As novas senhas não coincidem.'
    return
  }

  try {
    // monta payload incluindo senha se informada
    const payload = {
      user: {
        name: name.value,
        email: email.value,
        current_password: currentPassword.value
      }
    }
    if (newPassword.value) {
      payload.user.password = newPassword.value
      payload.user.password_confirmation = newPasswordConfirmation.value
    }

    const res = await fetch('/users', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf.value
      },
      credentials: 'same-origin',
      body: JSON.stringify(payload)
     })

     const data = await res.json().catch(() => null)

     if (res.ok && data) {
       formSuccess.value = 'Perfil atualizado com sucesso.'
       currentPassword.value = ''
       newPassword.value = ''
       newPasswordConfirmation.value = ''
       // atualiza navbar
       if (user.value) {
         user.value.name = data.name
         user.value.email = data.email
       }
     } else {
       formError.value = (data && data.error) || 'Falha ao atualizar perfil.'
     }

   } catch (e) {
     formError.value = e.message || 'Erro ao atualizar perfil.'
   }
}
</script>

<style scoped>
.card-title { color:#1A2E66; font-weight:700; }
@media (max-width:576px){ .card{ margin:0 1rem; } }
</style>
