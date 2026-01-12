<template>
  <!-- nova estrutura: marca | menus centralizados | ações (notificações + auth) -->
  <nav class="navbar navbar-expand-lg shadow-sm">
    <div class="container d-flex align-items-center">
      <!-- marca (esquerda) -->
      <div class="me-auto d-flex align-items-center">
        <router-link to="/" class="navbar-brand d-flex align-items-center">
          <img :src="logoSrc" class="logo-mark" alt="eDomi" />
        </router-link>
        <!-- modo: Site público / Sistema interno (apenas admin/corretor) -->
        <div v-if="isPrivileged" class="ms-2 position-relative" ref="modeRef">
          <button
            class="btn btn-mode-toggle"
            type="button"
            @click="toggleModeDropdown"
            :aria-expanded="modeOpen"
            aria-haspopup="true"
          >
            <i class="fa-solid fa-caret-down" aria-hidden="true"></i>
          </button>

          <div v-if="modeOpen" class="mode-menu shadow-sm">
            <button class="dropdown-item" type="button" @click="setMode('public')">Site público</button>
            <button class="dropdown-item" type="button" @click="setMode('internal')">Sistema interno</button>
          </div>
        </div>
      </div>

      <!-- menus centralizados -->
      <div class="mx-auto d-none d-lg-flex align-items-center">
        <!-- Public mode: show regular site menus (no Relatórios) -->
        <template v-if="mode === 'public'">
          <router-link to="/" class="btn btn-new mx-2">Imóveis</router-link>
          <router-link to="/about" class="btn btn-new mx-2">Sobre</router-link>
          <router-link to="/contact" class="btn btn-new mx-2">Contato</router-link>
          <router-link to="/calendar" class="btn btn-new mx-2">Visitas</router-link>
        </template>

        <!-- Internal mode: only show Relatórios (for privileged users) -->
        <template v-else>
          <div v-if="isPrivileged" class="nav-item mx-2 admin-items" ref="cadastrosRef">
            <button
              class="btn btn-new dropdown-toggle"
              type="button"
              @click="toggleCadastros"
              :aria-expanded="cadastrosOpen"
              aria-haspopup="true"
            >
              Relatórios
            </button>

            <div v-if="cadastrosOpen" class="cadastros-menu shadow-sm">
              <router-link class="dropdown-item" to="/admin/reports/properties" @click="closeCadastros">Imóveis</router-link>
              <router-link class="dropdown-item" to="/admin/reports/users" @click="closeCadastros">Usuários</router-link>
              <router-link class="dropdown-item" to="/admin/reports/sales" @click="closeCadastros">Vendas</router-link>
              <router-link class="dropdown-item" to="/admin/reports/commissions" @click="closeCadastros">Comissões</router-link>
              <router-link class="dropdown-item" to="/admin/reports/visits" @click="closeCadastros">Visitas</router-link>
            </div>
          </div>
        </template>
      </div>

      <!-- ações (direita): notificações + auth -->
      <div class="ms-auto d-flex align-items-center">
        <!-- notificações -->
        <div class="me-3 position-relative" ref="notificationsRef">
          <button
            class="btn btn-outline-light d-flex align-items-center position-relative"
            @click="toggleNotifications"
            :aria-expanded="notificationsOpen"
            aria-haspopup="true"
            type="button"
          >
            <!-- Font Awesome bell (carregado dinamicamente) -->
            <i class="fa-solid fa-bell notif-icon" aria-hidden="true"></i>
            <span v-if="unreadCount > 0" class="badge-unread">{{ unreadCount }}</span>
          </button>

          <div v-if="notificationsOpen" class="dropdown-menu-notifications shadow-sm">
            <div class="px-2 py-2" v-if="loadingNotifications">Carregando...</div>
            <div v-else>
              <div v-if="notifications.length === 0" class="px-3 py-2 small text-muted">Sem notificações</div>
              <button
                v-for="n in notifications"
                :key="n.id"
                class="dropdown-item btn-notif-item"
                type="button"
                :class="{ 'fw-bold': !n.read }"
                @click.prevent="openNotification(n)"
              >
                <div class="small text-secondary">{{ formatDate(n.created_at || n.createdAt || n.created) }}</div>
                <div>{{ n.title }}</div>
                <div class="small text-muted">{{ n.body }}</div>
              </button>
              <div class="dropdown-divider"></div>
              <router-link class="dropdown-item text-center small" to="/notifications">Ver todas as notificações</router-link>
            </div>
          </div>
        </div>

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
                <span class="d-none d-md-inline">{{ user.name || user.email }}</span>
              </button>

              <div v-if="dropdownOpen" class="dropdown-menu-custom shadow-sm">
                <router-link class="dropdown-item" to="/users/edit" @click.native="dropdownOpen=false">Perfil</router-link>
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

/* novo: src dinâmico para evitar resolução estática pelo Vite */
const logoSrc = '/logo_2.png'

const notifications = ref([])
const loadingNotifications = ref(false)

// mode: 'public' | 'internal' (default public)
const mode = ref('public')
const modeOpen = ref(false)
const modeRef = ref(null)

/* dropdown state and ref para click-outside */
const dropdownOpen = ref(false)
const userDropdownRef = ref(null)

/* notificações dropdown */
const notificationsOpen = ref(false)
const notificationsRef = ref(null)

/* novo: cadastros dropdown state e ref */
const cadastrosOpen = ref(false)
const cadastrosRef = ref(null)

const getCsrf = () => document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

const fetchCurrent = async () => {
  try {
    const res = await fetch('/current_user.json', {
      credentials: 'same-origin',
      headers: { 'Accept': 'application/json' }
    })
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

// computed helper para checar admin (lida com string/int)
const isAdmin = computed(() => {
  if (!user.value) return false
  const r = user.value.role
  return r === 'admin' || r === '2' || r === 2
})

// novo: isAgent
const isAgent = computed(() => {
  if (!user.value) return false
  const r = user.value.role
  return r === 'agent' || r === '1' || r === 1
})

// privileged users (admin or agent)
const isPrivileged = computed(() => isAdmin.value || isAgent.value)

// no fetchNotifications
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
      // garante que read seja booleano
      const newNotifs = (data || []).map(n => ({
        ...n,
        read: n.read === true || n.read === "true" || n.read === 1 || n.read === "1"
      }))

      // mescla mantendo o read local se já existia
      const existingMap = new Map(notifications.value.map(n => [n.id, n]))
      notifications.value = newNotifs.map(n => {
        if (existingMap.has(n.id)) {
          return { ...n, read: existingMap.get(n.id).read }
        }
        return n
      })
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

// badge
const unreadCount = computed(() =>
  notifications.value.filter(n => n.read === false).length
)


const toggleDropdown = () => {
  dropdownOpen.value = !dropdownOpen.value
}

const toggleNotifications = () => {
  notificationsOpen.value = !notificationsOpen.value
}

const toggleCadastros = () => {
  cadastrosOpen.value = !cadastrosOpen.value
}
const closeCadastros = () => { cadastrosOpen.value = false }

const toggleModeDropdown = () => { modeOpen.value = !modeOpen.value }
const setMode = (m) => {
  if (m !== 'public' && m !== 'internal') return
  mode.value = m
  try { localStorage.setItem('nav_mode', m) } catch (e) {}
  modeOpen.value = false
  // navigate to the corresponding main component
  if (m === 'public') {
    router.push({ name: 'home' }).catch(() => {})
  } else {
    // internal
    router.push({ name: 'internal' }).catch(() => {})
  }
}

/* atualiza onDocumentClick para fechar cadastros se clicar fora */
const onDocumentClick = (e) => {
  if (dropdownOpen.value && userDropdownRef.value && !userDropdownRef.value.contains(e.target)) {
    dropdownOpen.value = false
  }
  if (notificationsOpen.value && notificationsRef.value && !notificationsRef.value.contains(e.target)) {
    notificationsOpen.value = false
  }
  if (cadastrosOpen.value && cadastrosRef.value && !cadastrosRef.value.contains(e.target)) {
    cadastrosOpen.value = false
  }
  if (modeOpen.value && modeRef.value && !modeRef.value.contains(e.target)) {
    modeOpen.value = false
  }
}

onMounted(async () => {
  try {
    const res = await fetch('/current_user', { credentials: 'same-origin' })
    if (res.ok) {
      user.value = await res.json()
    }
  } catch (e) {
    user.value = null
  }

  // liga listener para fechar dropdowns ao clicar fora
  document.addEventListener('click', onDocumentClick)

  // restaura modo salvo (se houver). padrão: public
  try {
    const stored = localStorage.getItem('nav_mode')
    if (stored === 'internal') mode.value = 'internal'
    else mode.value = 'public'
  } catch (e) {
    mode.value = 'public'
  }
  // navigate to persisted mode if privileged
  try {
    if (mode.value === 'internal' && isPrivileged.value) {
      router.replace({ name: 'internal' }).catch(() => {})
    } else {
      router.replace({ name: 'home' }).catch(() => {})
    }
  } catch (e) {}

  // processa alertas já presentes e observa novos
  processExistingAlerts()
  startObservingAlerts()
})

const alertObserver = ref(null)
const pendingTimeouts = []

const scheduleAutoDismiss = (el) => {
  try {
    if (!el || el.dataset?.autodismissed) return

    // NÃO auto-fechar alerts que estejam dentro de um formulário ou de um card de formulário.
    // cobre casos onde o alert é irmão do <form> (ex. dentro de .form-card) — evita remoção de mensagens de validação
    if (
      (el.closest && el.closest('form')) ||
      (el.closest && el.closest('.form-card')) ||
      (el.closest && el.closest('.property-form-container')) ||
      (el.closest && el.closest('[role="form"]')) ||
      el.dataset && el.dataset.persistAlert === 'true'
    ) {
      return
    }

    // respeita flag para não auto-fechar
    if (el.dataset && el.dataset.autoclose === 'false') return
    if (el.classList && el.classList.contains('no-autoclose')) return

    el.dataset.autodismissed = '1'

    const timeoutId = setTimeout(() => {
      // tenta usar botão de fechar nativo (Bootstrap 5 usa .btn-close)
      const closeBtn = el.querySelector('.btn-close, button.close')
      if (closeBtn) {
        try { closeBtn.click() } catch (e) { /* fallback abaixo */ }
      } else {
        // anima e remove
        el.style.transition = 'opacity 360ms ease'
        el.style.opacity = '0'
        setTimeout(() => {
          if (el.parentNode) el.parentNode.removeChild(el)
        }, 380)
      }
    }, 5000)

    pendingTimeouts.push(timeoutId)
  } catch (e) {
    // não bloquear a aplicação por erro de UI
  }
}

const processExistingAlerts = () => {
  try {
    const list = Array.from(document.querySelectorAll('.alert[role="alert"], .alert'))
    list.forEach(el => scheduleAutoDismiss(el))
  } catch (e) {}
}

const startObservingAlerts = () => {
  if (typeof MutationObserver === 'undefined') return
  alertObserver.value = new MutationObserver((mutations) => {
    mutations.forEach(m => {
      m.addedNodes && m.addedNodes.forEach(node => {
        if (!node || node.nodeType !== 1) return
        const el = node
        if (el.matches && (el.matches('.alert') || el.matches('[role="alert"]'))) {
          scheduleAutoDismiss(el)
        }
        // também busca alerts dentro do nó adicionado
        const inner = el.querySelectorAll && el.querySelectorAll('.alert[role="alert"], .alert')
        if (inner && inner.length) Array.from(inner).forEach(i => scheduleAutoDismiss(i))
      })
    })
  })
  alertObserver.value.observe(document.body, { childList: true, subtree: true })
}

onBeforeUnmount(() => {
  document.removeEventListener('click', onDocumentClick)
  if (alertObserver.value) {
    try { alertObserver.value.disconnect() } catch (e) {}
    alertObserver.value = null
  }
  // limpa timeouts pendentes
  pendingTimeouts.forEach(id => {
    try { clearTimeout(id) } catch (e) {}
  })
  pendingTimeouts.length = 0
})

const logout = async () => {
  try {
    const res = await fetch('/users/sign_out', {
      method: 'DELETE',
      headers: { 'X-CSRF-Token': getCsrf(), 'Accept': 'application/json' },
      credentials: 'same-origin'
    })
    if (res.ok || res.status === 204) {
      window.location.href = '/'
    } else if (res.status === 303) {
      window.location.href = '/'
    } else {
      const txt = await res.text().catch(() => '')
      alert('Falha no logout: ' + txt)
    }
  } catch (e) {
    alert('Erro ao efetuar logout.')
  }
}

const formatDate = (iso) => {
  try {
    const d = new Date(iso)
    if (isNaN(d)) return iso
    const dd = String(d.getDate()).padStart(2, '0')
    const mm = String(d.getMonth() + 1).padStart(2, '0')
    const yy = String(d.getFullYear()).slice(-2)
    return `${dd}/${mm}/${yy}`
  } catch (e) {
    return iso
  }
}

const openNotification = async (n) => {
  try {
    await fetch(`/notifications/${n.id}/mark_as_read`, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': getCsrf(),
        'Content-Type': 'application/json',
      },
      credentials: 'same-origin',
    })
  } catch (e) {
    console.warn('Falha ao marcar notificação como lida', e)
  }

  // marca localmente como lida
  const notif = notifications.value.find(x => x.id === n.id)
  if (notif) notif.read = true

  // navegação para a data relacionada
  const candidate = n.scheduled_at || n.date || n.created_at || n.createdAt || n.created || ''
  let dateParam = ''
  if (candidate) {
    dateParam = String(candidate).split('T')[0]
    if (!/^\d{4}-\d{2}-\d{2}$/.test(dateParam)) {
      const parsed = new Date(candidate)
      if (!isNaN(parsed)) {
        const y = parsed.getFullYear()
        const m = String(parsed.getMonth() + 1).padStart(2, '0')
        const d = String(parsed.getDate()).padStart(2, '0')
        dateParam = `${y}-${m}-${d}`
      }
    }
  }

  if (dateParam) {
    router.push({ name: 'calendar', query: { date: dateParam } }).catch(() => {})
  } else {
    router.push({ name: 'calendar' }).catch(() => {})
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
  width: 80px;
  height: auto;
  padding-top: 4px;
  padding-bottom: 4px;
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

  /* garante que menus custom fiquem sempre acima de outros elementos da página */
  z-index: 4000;
}

/* notifications dropdown: garantir que fique acima de outros componentes */
.dropdown-menu-notifications {
  z-index: 3000; /* valor suficientemente alto para estar acima de cards/modals */
  position: absolute;
  right: 0;
  top: calc(100% + 6px);
  width: 320px;
  max-height: 360px;
  background: #ffffff;
  border-radius: 0.35rem;
  box-shadow: 0 6px 18px rgba(0,0,0,0.12);
  padding: 0.25rem 0;
  overflow: auto;
}

/* remove mudança para branco nos botões de usuário e notificações */
.btn-outline-light:hover,
.btn-outline-light:focus,
.btn-outline-light:active {
  color: inherit;        /* mantém a cor original (#fff do navbar) */
  background-color: rgba(255,255,255,0.1); /* leve efeito visual de hover */
  border-color: rgba(255,255,255,0.2);    /* mantém borda */
}

/* estilo do ícone do sino (usa Font Awesome) */
.notif-icon {
  color: #fff;
  font-size: 18px;
  line-height: 1;
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

.btn-notif-item { text-align: left; width: 100%; background: transparent; border: none; padding: 0.5rem 1rem; }

.dropdown-item:hover {
  background: #f8f9fa;
  color: #000;
}

.dropdown-divider {
  height: 1px;
  margin: 0.25rem 0;
  background: #e9ecef;
}

/* unread badge */
.badge-unread {
  position: absolute;
  top: -5px;
  right: -5px;
  background: #ff4d4f;
  color: #fff;
  font-size: 0.65rem;
  padding: 2px 6px;
  border-radius: 999px;
  line-height: 1;
}

/* adaptações pequenas */
@media (max-width: 576px) {
  .logo-text { font-size: 0.95rem; }
  .logo-mark { width: 28px; height: 28px; }
  .user-dropdown .small { display: none !important; }
}

/* melhora visual do botão dentro do dropdown (mantém estilo do theme) */
.dropdown-menu .dropdown-item {
  color: #333;
}
.dropdown-menu .dropdown-item:hover {
  background: #f8f9fa;
}

/* menu custom para cadastros (mesma sintaxe visual dos menus customizados) */
.cadastros-menu {
  position: absolute;
  left: 0;
  top: calc(100% + 6px);
  min-width: 220px;
  background: #ffffff;
  border-radius: 0.35rem;
  box-shadow: 0 6px 24px rgba(0,0,0,0.12);
  padding: 0.25rem 0;
  z-index: 3000;
}

/* mode dropdown (next to logo) */
.btn-mode-toggle {
  background: transparent;
  border: none;
  color: #ffffff;
  padding: 0.15rem 0.35rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 0.85rem;
  cursor: pointer;
}
.btn-mode-toggle:hover { color: var(--secondary-green); }

.mode-menu {
  position: absolute;
  left: 0;
  top: calc(100% + 6px);
  min-width: 160px;
  background: #ffffff;
  border-radius: 0.35rem;
  box-shadow: 0 6px 18px rgba(0,0,0,0.12);
  padding: 0.25rem 0;
  z-index: 4000;
}

/* itens do menu */
.cadastros-menu .dropdown-item {
  display: block;
  padding: 0.5rem 1rem;
  color: #333;
  text-decoration: none;
}
.cadastros-menu .dropdown-item:hover {
  background: #f8f9fa;
  color: #000;
}

/* adaptações para posicionamento do botão dropdown */
.nav-item.mx-2 { position: relative; }

.admin-items {
  margin-left: 4rem !important;
}
</style>
