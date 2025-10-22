<template>
  <div class="d-flex justify-content-center align-items-center py-5">
    <div class="card shadow-sm" style="max-width:520px; width:100%;">
      <div class="card-body">
        <h5 class="card-title mb-3">Redefinir senha</h5>

        <form action="/users/password" method="post" class="needs-validation" novalidate>
          <input type="hidden" name="authenticity_token" :value="csrf" />
          <!-- Devise espera PUT para atualizar senha -->
          <input type="hidden" name="_method" value="put" />

          <p class="small text-muted">Cole o código recebido por e‑mail (ou use o link recebido). Em seguida escolha sua nova senha.</p>

          <div class="mb-3">
            <label class="form-label">Código / Token</label>
            <input name="user[reset_password_token]" type="text" class="form-control" v-model="tokenInput" />
          </div>

          <div class="mb-3">
            <label class="form-label">Nova senha</label>
            <input name="user[password]" type="password" class="form-control" required minlength="6" />
            <div class="form-text small">Mínimo 6 caracteres.</div>
          </div>

          <div class="mb-3">
            <label class="form-label">Confirme a nova senha</label>
            <input name="user[password_confirmation]" type="password" class="form-control" required minlength="6" />
          </div>

          <div class="d-grid">
            <button type="submit" class="btn" style="background:#1A2E66; color:#fff; border-color:#1A2E66;">Redefinir senha</button>
          </div>
        </form>

        <hr />

        <div class="text-center small">
          Lembrou? <a href="/users/sign_in">Entrar</a>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const csrf = ref(document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '')
// captura token da query string, se presente
const token = (new URLSearchParams(window.location.search)).get('reset_password_token') || ''
const tokenInput = ref(token)
</script>

<style scoped>
.card-title { color:#1A2E66; font-weight:700; }
@media (max-width: 576px) {
  .card { margin: 0 1rem; }
}
</style>
