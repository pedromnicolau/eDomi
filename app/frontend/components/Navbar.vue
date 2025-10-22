<template>
  <!-- nova estrutura: marca | menus centralizados | ações (notificações + auth) -->
  <nav class="navbar navbar-expand-lg shadow-sm">
    <div class="container d-flex align-items-center">
      <!-- marca (esquerda) -->
      <div class="me-auto d-flex align-items-center">
        <router-link to="/" class="navbar-brand d-flex align-items-center">
          <span class="logo-mark" aria-hidden="true"></span>
          <span class="logo-text">eDomi</span>
        </router-link>
      </div>

      <!-- menus centralizados -->
      <div class="mx-auto d-none d-lg-flex align-items-center">
        <router-link to="/" class="btn btn-new mx-2">Início</router-link>
        <router-link to="/about" class="btn btn-new mx-2">Sobre</router-link>
        <router-link to="/contact" class="btn btn-new mx-2">Contato</router-link>
      </div>

      <!-- ações (direita): notificações + auth -->
      <div class="ms-auto d-flex align-items-center">
        <!-- auth -->
        <div class="d-flex align-items-center">
          <template v-if="user">
            <div class="user-dropdown position-relative" ref="userDropdownRef">
              <button
                class="btn btn-outline-light d-flex align-items-center"
                @click="toggleDropdown"
                :aria-expanded="dropdownOpen"
                aria-haspopup="true"
                type="button"
              >
                <!-- simple user icon -->
                <svg class="me-2 user-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
                  <path d="M12 12c2.761 0 5-2.239 5-5s-2.239-5-5-5-5 2.239-5 5 2.239 5 5 5z" fill="#fff"/>
                  <path d="M4 20c0-4.418 3.582-8 8-8s8 3.582 8 8" stroke="#fff" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                <span class="small text-white d-none d-md-inline">{{ user.name || user.email }}</span>
              </button>

              <div v-if="dropdownOpen" class="dropdown-menu-custom shadow-sm">
                <a class="dropdown-item" href="/users/edit">Editar perfil</a>
                <router-link class="dropdown-item" to="/users/password/change">Alterar senha</router-link>
                <div class="dropdown-divider"></div>
                <button class="dropdown-item text-danger" @click="logout" type="button">Sair</button>
              </div>
            </div>
          </template>
          <template v-else>
            <router-link class="btn btn-outline-light me-2" to="/users/sign_in">Entrar</router-link>
            <router-link class="btn btn-light" to="/users/sign_up">Registrar</router-link>
          </template>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted, watch, computed, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const user = ref(null)
const canCreate = ref(false)

const notifications = ref([])
const loadingNotifications = ref(false)

/* dropdown state and ref para click-outside */
const dropdownOpen = ref(false)
const userDropdownRef = ref(null)

const getCsrf = () => document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

const fetchCurrent = async () => {
  try {
    const res = await fetch('/current_user', { credentials: 'same-origin' })
    if (res.ok) {
      const data = await res.json()
      user.value = data
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

const toggleDropdown = () => {
  dropdownOpen.value = !dropdownOpen.value
}

const onDocumentClick = (e) => {
  if (dropdownOpen.value && userDropdownRef.value && !userDropdownRef.value.contains(e.target)) {
    dropdownOpen.value = false
  }
}

onMounted(async () => {
  document.addEventListener('click', onDocumentClick)
  await fetchCurrent()
  if (user.value) await fetchNotifications()
})

onBeforeUnmount(() => {
  document.removeEventListener('click', onDocumentClick)
})

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

/* pequenas adaptações visuais */
.btn-outline-light { color: #ffffff; border-color: rgba(255,255,255,0.2); }
.btn-light { background: #ffffff; color: #1A2E66; }

/* user dropdown */
.user-icon { display: inline-block; vertical-align: middle; }
.user-dropdown { z-index: 1050; }

/* custom dropdown styling */
.dropdown-menu-custom {
  position: absolute;
  right: 0;
  top: calc(100% + 6px);
  min-width: 200px;
  background: #ffffff;
  border-radius: 0.35rem;
  box-shadow: 0 6px 18px rgba(0,0,0,0.12);
  padding: 0.25rem 0;
  overflow: hidden;
}

/* items */
.dropdown-item {
  display: block;
  width: 100%;
  padding: 0.5rem 1rem;
  color: #333;
  text-decoration: none;
  background: transparent;
  border: none;
  text-align: left;
}

.dropdown-item:hover {
  background: #f8f9fa;
  color: #000;
}

.dropdown-divider {
  height: 1px;
  margin: 0.25rem 0;
  background: #e9ecef;
}

/* adaptações pequenas */
@media (max-width: 576px) {
  .logo-text { font-size: 0.95rem; }
  .logo-mark { width: 28px; height: 28px; }
  .user-dropdown .small { display: none !important; }
}
</style>
