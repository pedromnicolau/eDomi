<template>
  <div class="d-flex justify-content-center py-5">
    <div class="card shadow-sm" style="max-width:520px; width:100%;">
      <div class="card-body">
        <h5 class="card-title mb-3">Alterar senha</h5>

        <form ref="form" @submit.prevent="onSubmit" action="/users" method="post" class="needs-validation" novalidate>
          <input type="hidden" name="authenticity_token" :value="csrf" />
          <input type="hidden" name="_method" value="put" />

          <div class="mb-3">
            <label class="form-label">Senha atual</label>
            <input name="user[current_password]" v-model="currentPassword" type="password" class="form-control" required />
          </div>

          <div class="mb-3">
            <label class="form-label">Nova senha</label>
            <input name="user[password]" v-model="password" type="password" class="form-control" required minlength="6" />
            <div class="form-text small">Mínimo 6 caracteres.</div>
          </div>

          <div class="mb-3">
            <label class="form-label">Confirme a nova senha</label>
            <input name="user[password_confirmation]" v-model="passwordConfirmation" type="password" class="form-control" required minlength="6" />
            <div v-if="mismatch" class="text-danger small mt-1">As senhas não coincidem.</div>
          </div>

          <div class="d-grid">
            <button type="submit" class="btn" :disabled="mismatch || !password" style="background:#1A2E66; color:#fff;">Alterar senha</button>
          </div>
        </form>

        <hr />
        <div class="text-center small">
          <a href="/users/edit">Voltar ao perfil</a>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
const csrf = ref(document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '')
const currentPassword = ref('')
const password = ref('')
const passwordConfirmation = ref('')
const form = ref(null)

const mismatch = computed(() => passwordConfirmation.value.length > 0 && (password.value !== passwordConfirmation.value))

const onSubmit = () => {
  if (mismatch.value) return
  form.value && form.value.submit()
}
</script>

<style scoped>
.card-title { color:#1A2E66; font-weight:700; }
@media (max-width:576px){ .card{ margin:0 1rem; } }
</style>
