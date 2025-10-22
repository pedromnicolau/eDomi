<template>
  <div class="d-flex justify-content-center align-items-center py-5">
    <div class="card shadow-sm" style="max-width:420px; width:100%;">
      <div class="card-body">
        <h5 class="card-title mb-3">Entrar</h5>
        <form action="/users/sign_in" method="post" class="needs-validation" novalidate>
          <input type="hidden" name="authenticity_token" :value="csrf" />

          <div class="mb-3">
            <label class="form-label">E‑mail</label>
            <input name="user[email]" type="email" class="form-control" required />
          </div>

          <div class="mb-3">
            <label class="form-label">Senha</label>
            <input name="user[password]" type="password" class="form-control" required />
          </div>

          <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
              <input type="checkbox" id="remember" name="user[remember_me]" value="1" />
              <label for="remember" class="form-check-label ms-1 small">Lembrar</label>
            </div>
            <a href="/users/password/new" class="small">Esqueceu a senha?</a>
          </div>

          <div class="d-grid">
            <button type="submit" class="btn btn-primary" style="background:#1A2E66; border-color:#1A2E66;">Entrar</button>
          </div>
        </form>

        <hr />

        <div class="text-center small">
          Ainda não tem conta? <a href="/users/sign_up">Registre‑se</a>
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
.btn-primary { color:#fff; }
@media (max-width: 576px) {
  .card { margin: 0 1rem; }
}
</style>
