<template>
  <div class="d-flex justify-content-center align-items-center py-5">
    <div class="card shadow-sm" style="max-width:520px; width:100%;">
      <div class="card-body">
        <h5 class="card-title mb-3">Esqueceu a senha?</h5>

        <form action="/users/password" method="post" class="needs-validation" novalidate>
          <input type="hidden" name="authenticity_token" :value="csrf" />

          <p class="small text-muted">Informe o e‑mail cadastrado. Enviaremos um código/link para redefinir sua senha.</p>

          <div class="mb-3">
            <label class="form-label">E‑mail</label>
            <input name="user[email]" type="email" class="form-control" required />
          </div>

          <div class="d-grid">
            <button type="submit" class="btn" style="background:#1A2E66; color:#fff; border-color:#1A2E66;">Enviar código</button>
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
</script>

<style scoped>
.card-title { color:#1A2E66; font-weight:700; }
@media (max-width: 576px) {
  .card { margin: 0 1rem; }
}
</style>
