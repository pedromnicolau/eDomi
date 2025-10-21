<template>
  <nav class="navbar navbar-expand-lg shadow-sm">
    <div class="container">
      <router-link to="/" class="navbar-brand d-flex align-items-center">
        <span class="logo-mark" aria-hidden="true"></span>
        <span class="logo-text">eDomi</span>
      </router-link>

      <button
        class="navbar-toggler"
        type="button"
        data-bs-toggle="collapse"
        data-bs-target="#mainNavbar"
        aria-controls="mainNavbar"
        aria-expanded="false"
        aria-label="Alternar navegação"
      >
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="mainNavbar">
        <ul class="navbar-nav ms-auto mb-2 mb-lg-0 align-items-lg-center">
          <li>
            <router-link to="/" class="btn btn-new ms-3">Início</router-link>
          </li>
          <li>
            <router-link to="/about" class="btn btn-new ms-3">Sobre</router-link>
          </li>
          <li>
            <router-link to="/properties/new" class="btn btn-new ms-3">Novo imóvel</router-link>
          </li>
        </ul>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const user = ref(null)
const canCreate = ref(false)

const getCsrf = () => document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

const fetchCurrent = async () => {
  try {
    const res = await fetch('/current_user')
    if (res.ok) {
      user.value = await res.json()
      canCreate.value = user.value && (user.value.role === 'agent' || user.value.role === 'admin')
    } else {
      user.value = null
      canCreate.value = false
    }
  } catch (e) {
    user.value = null
    canCreate.value = false
  }
}

const logout = async () => {
  try {
    const res = await fetch('/users/sign_out', {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': getCsrf()
      },
      credentials: 'same-origin'
    })
    if (res.ok || res.status === 302 || res.status === 204) {
      window.location.reload()
    } else {
      const txt = await res.text()
      alert('Falha no logout: ' + txt)
    }
  } catch (e) {
    alert('Erro ao efetuar logout.')
  }
}

onMounted(fetchCurrent)
</script>

<style scoped>
.navbar {
  background: #1A2E66;
  padding: 0.30rem 0.5rem;
  --primary-blue: #1A2E66;
  --secondary-green: #4ADE80;
  border-radius: 0.35rem;
  display: flex;
  border-radius: 0;
  display: flex;
  align-items: center;
  margin: 0;
  width: 100%;
}

/* logo */
.logo-mark {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  display: inline-flex;;
  align-items: center;
  background: linear-gradient(135deg, var(--primary-blue) 0%, var(--secondary-green) 100%);
  box-shadow: 0 4px 10px rgba(26,46,102,0.12);
  flex-shrink: 0;
  margin-right: 0.5rem;
}

.logo-text {
  color: #ffffff;
  display: inline-flex;
  align-items: center;
  font-weight: 700;
  font-size: 1rem;
  letter-spacing: 0.2px;
}

.nav-link:hover { 
  color: var(--secondary-green);
  text-decoration: none;
}

/* botão */
.btn-new {
  color: #ffffff;
  border: 0;
  padding: 0.4rem 0.85rem;
  border-radius: 0.375rem;
  font-weight: 600;
}

.btn-new:hover {
  color: var(--secondary-green);
}
.navbar-toggler {
  padding: 0.25rem 0.5rem;
}
.navbar-toggler-icon { opacity: 0.6; }

@media (max-width: 576px) {
  .logo-text { font-size: 0.95rem; }
  .logo-mark { width: 28px; height: 28px; }
}
</style>
