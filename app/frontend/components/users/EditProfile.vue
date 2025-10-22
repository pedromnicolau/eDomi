<template>
  <div class="d-flex justify-content-center py-5">
    <div class="card shadow-sm" style="max-width:560px; width:100%;">
      <div class="card-body">
        <h5 class="card-title mb-3">Editar perfil</h5>

        <form ref="form" action="/users" method="post" class="needs-validation" novalidate>
          <input type="hidden" name="authenticity_token" :value="csrf" />
          <input type="hidden" name="_method" value="put" />

          <div class="mb-3">
            <label class="form-label">Nome</label>
            <input name="user[name]" v-model="name" type="text" class="form-control" required />
          </div>

          <div class="mb-3">
            <label class="form-label">E‑mail</label>
            <input name="user[email]" v-model="email" type="email" class="form-control" required />
          </div>

          <div class="mb-3">
            <label class="form-label">Senha atual (confirmação)</label>
            <input name="user[current_password]" v-model="currentPassword" type="password" class="form-control" required />
            <div class="form-text small">Informe a senha atual para confirmar alterações.</div>
          </div>

          <div class="d-grid">
            <button type="submit" class="btn" style="background:#1A2E66; color:#fff;">Salvar alterações</button>
          </div>
        </form>

        <hr />
        <div class="text-center small">
          <a href="/">Cancelar</a>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const csrf = ref(document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '')
const name = ref('')
const email = ref('')
const currentPassword = ref('')

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
</script>

<style scoped>
.card-title { color:#1A2E66; font-weight:700; }
@media (max-width:576px){ .card{ margin:0 1rem; } }
</style>
