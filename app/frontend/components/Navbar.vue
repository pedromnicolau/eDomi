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
          <div class="dropdown me-3" @mouseleave="dropdownOpen = false">
            <button class="btn btn-link position-relative" @click="toggleDropdown" :aria-expanded="dropdownOpen">
              <i class="bi bi-bell" style="font-size:1.25rem;"></i>
              <span v-if="unreadCount > 0" class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                {{ unreadCount }}
              </span>
            </button>

            <div class="dropdown-menu dropdown-menu-end p-2" v-show="dropdownOpen" style="min-width:340px; max-height:400px; overflow:auto;">
              <div class="d-flex justify-content-between align-items-center mb-2">
                <strong class="me-2">Notificações</strong>
                <small class="text-muted">{{ notifications.length }} recentes</small>
              </div>

              <div v-if="loadingNotifications" class="text-center small text-muted">Carregando...</div>

              <div v-else-if="!user" class="small text-muted">Faça login para ver notificações.</div>

              <div v-else-if="notifications.length === 0" class="small text-muted">Nenhuma notificação.</div>

              <div v-else>
                <div v-for="n in notifications" :key="n.id" class="dropdown-item py-2">
                  <div class="fw-bold">{{ n.title }}</div>
                  <div class="text-truncate" :title="n.body">{{ n.body }}</div>
                  <div class="text-muted small">{{ formatDate(n.created_at) }}</div>
                </div>
              </div>

              <div class="dropdown-divider"></div>
              <div class="text-center">
                <router-link class="small" to="/notifications">Ver todas</router-link>
              </div>
            </div>
          </div>
        </ul>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted, watch, computed } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const user = ref(null)
const canCreate = ref(false)

const notifications = ref([])
const loadingNotifications = ref(false)
const dropdownOpen = ref(false)

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

const fetchNotifications = async () => {
  if (!user.value) {
    notifications.value = []
    return
  }
  loadingNotifications.value = true
  try {
    const res = await fetch('/notifications.json', { credentials: 'same-origin' })
    if (res.ok) {
      const data = await res.json()
      notifications.value = data || []
    } else {
      notifications.value = []
    }
  } catch (e) {
    console.error('Erro ao buscar notificações', e)
    notifications.value = []
  } finally {
    loadingNotifications.value = false
  }
}

const unreadCount = computed(() => notifications.value.filter(n => !n.read).length)

const toggleDropdown = async () => {
  dropdownOpen.value = !dropdownOpen.value
  if (dropdownOpen.value) {
    await fetchNotifications()
    // opcional: marcar como lidas via endpoint se implementado
  }
}

const logout = async () => {
  try {
    const res = await fetch('/users/sign_out', {
      method: 'DELETE',
      headers: { 'X-CSRF-Token': getCsrf() },
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

const formatDate = (iso) => {
  try {
    return new Date(iso).toLocaleString()
  } catch (e) {
    return iso
  }
}

onMounted(async () => {
  await fetchCurrent()
  if (user.value) await fetchNotifications()
})

// quando o usuário muda (ex.: faz login via SPA), buscar notificações
watch(user, async (v) => {
  if (v) await fetchNotifications()
})
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
