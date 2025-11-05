<template>
  <div class="admin-panel">
    <div class="container">
      <div class="admin-toolbar d-flex align-items-center mb-3">
        <h3 class="me-auto">Cadastros — Pessoas</h3>
        <div class="d-flex align-items-center">
          <button class="btn add-btn btn-sm" @click="addNew">+</button>
        </div>
      </div>

      <div class="filters-wrap my-3">
        <div class="filters-row row g-2 align-items-center">
          <div class="col-md-4">
            <input v-model="filterName" class="form-control form-control-sm" placeholder="Filtrar por nome..." />
          </div>
          <div class="col-md-3">
            <input v-model="filterEmail" class="form-control form-control-sm" placeholder="Filtrar por email..." />
          </div>
          <div class="col-md-3">
            <input v-model="filterPhone" class="form-control form-control-sm" placeholder="Filtrar por telefone..." />
          </div>
          <div class="col-md-2 text-md-end">
            <select v-model="filterStatus" class="form-control form-control-sm">
              <option value="">Todos</option>
              <option value="prospect">Prospect</option>
              <option value="client">Cliente</option>
              <option value="inactive">Inativo</option>
            </select>
          </div>
        </div>
      </div>

      <div class="admin-card">
        <div v-if="loading" class="text-muted">Carregando...</div>
        <div v-else class="table-responsive">
          <table class="table table-sm">
            <thead>
              <tr>
                <th>Nome</th>
                <th>Email</th>
                <th>Telefone</th>
                <th>Status</th>
                <th>Agente</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="p in filtered" :key="p.id" @contextmenu.prevent.stop="openMenu($event, p)">
                <td><router-link :to="{ name: 'people-show', params: { id: p.id }}">{{ p.name || '-' }}</router-link></td>
                <td>{{ p.email || '-' }}</td>
                <td>{{ p.phone || '-' }}</td>
                <td>{{ p.status || '-' }}</td>
                <td>{{ p.assigned_agent_name || '-' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <teleport to="body">
        <div v-if="menuVisible" class="context-menu" :style="{ left: menuX + 'px', top: menuY + 'px' }" @click.stop>
          <ul>
            <li @click="viewRecord(menuRecord)">Ver</li>
            <li @click="editRecord(menuRecord)">Editar</li>
            <li class="danger" @click="deleteRecord(menuRecord)">Excluir</li>
          </ul>
        </div>
      </teleport>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { useRouter } from 'vue-router'
const router = useRouter()

const records = ref([])
const loading = ref(false)

// filtros
const filterName = ref('')
const filterEmail = ref('')
const filterPhone = ref('')
const filterStatus = ref('')

const fetchRecords = async () => {
  loading.value = true
  try {
    const res = await fetch('/people.json', { credentials: 'same-origin' })
    if (res.ok) records.value = await res.json()
    else records.value = []
  } catch (e) { records.value = [] }
  loading.value = false
}

onMounted(fetchRecords)

const filtered = computed(() => {
  const list = records.value || []
  const n = String(filterName.value || '').trim().toLowerCase()
  const em = String(filterEmail.value || '').trim().toLowerCase()
  const ph = String(filterPhone.value || '').trim().toLowerCase()
  const st = String(filterStatus.value || '').trim().toLowerCase()

  return list.filter(r => {
    if (n && !String(r.name || '').toLowerCase().includes(n)) return false
    if (em && !String(r.email || '').toLowerCase().includes(em)) return false
    if (ph && !String(r.phone || '').toLowerCase().includes(ph)) return false
    if (st && !String(r.status || '').toLowerCase().includes(st)) return false
    return true
  })
})

const addNew = () => {
  router.push({ name: 'sign-up' }).catch(()=>{})
}

// menu contextual
const menuVisible = ref(false)
const menuX = ref(0)
const menuY = ref(0)
const menuRecord = ref(null)

const openMenu = async (e, rec) => {
  const initialX = Math.max(8, e.clientX || 0)
  const initialY = Math.max(8, e.clientY || 0)

  menuRecord.value = rec
  menuX.value = initialX
  menuY.value = initialY
  menuVisible.value = true

  await nextTick()
  const menuEl = document.querySelector('.context-menu')
  if (menuEl) {
    const mw = menuEl.offsetWidth
    const mh = menuEl.offsetHeight
    const margin = 8
    const vw = window.innerWidth
    const vh = window.innerHeight
    if (menuX.value + mw + margin > vw) menuX.value = Math.max(margin, vw - mw - margin)
    if (menuY.value + mh + margin > vh) menuY.value = Math.max(margin, vh - mh - margin)
  }
}

const closeMenu = () => {
  menuVisible.value = false
  menuRecord.value = null
}

const onGlobalClick = (ev) => {
  if (!menuVisible.value) return
  const menuEl = document.querySelector('.context-menu')
  if (!menuEl) return closeMenu()
  if (!menuEl.contains(ev.target)) closeMenu()
}
const onKeyDown = (ev) => { if (ev.key === 'Escape' && menuVisible.value) closeMenu() }

onMounted(() => {
  window.addEventListener('click', onGlobalClick)
  window.addEventListener('keydown', onKeyDown)
})

onBeforeUnmount(() => {
  window.removeEventListener('click', onGlobalClick)
  window.removeEventListener('keydown', onKeyDown)
})

const viewRecord = (rec) => {
  if (!rec) return
  router.push({ name: 'people-show', params: { id: rec.id } }).catch(()=>{})
  closeMenu()
}
const editRecord = (rec) => {
  if (!rec) return
  router.push({ name: 'people-edit', params: { id: rec.id } }).catch(()=>{
    router.push({ path: `/people/${rec.id}/edit` }).catch(()=>{})
  })
  closeMenu()
}
const deleteRecord = async (rec) => {
  if (!rec) return
  const label = rec.name || `#${rec.id}`
  if (!confirm(`Confirmar exclusão de "${label}"?`)) { closeMenu(); return }
  try {
    const res = await fetch(`/people/${rec.id}`, { method: 'DELETE', credentials: 'same-origin', headers: { 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') } })
    if (res.ok) {
      records.value = records.value.filter(r => r.id !== rec.id)
    } else {
      alert('Falha ao excluir o registro.')
    }
  } catch (e) {
    alert('Erro ao excluir o registro.')
  }
  closeMenu()
}
</script>

<style scoped>
/* Reaproveita estilos já presentes no projeto (copiado do componente de imóveis) */
/* ...existing CSS from CadastrosProperties.vue is recommended... */

/* minimal adjustments */
.admin-panel { padding: 1.25rem 0 2.5rem; }
.container { max-width: 1140px; margin: 0 auto; padding-left: 24px; padding-right: 24px; }
.add-btn { background: #4ADE80; color: #08203a; border: 0; font-weight: 600; border-radius: 999px; padding: 0.42rem 0.9rem; }
.context-menu { position: fixed; min-width: 140px; background: #fff; border-radius: 8px; box-shadow: 0 12px 30px rgba(15,35,77,0.18); padding: 6px; z-index: 9999; }
</style>
