<template>
  <div class="admin-panel">
    <div class="container">
      <div class="admin-toolbar d-flex align-items-center mb-3">
        <h3 class="me-auto">Relatório — Imóveis</h3>
          <div class="d-flex align-items-center">
            <div class="col-md-4">
              <input v-model="filterTitle" class="form-control form-control-sm" placeholder="Filtrar por título" />
            </div>
            <div class="col-md-4">
              <input v-model="filterCity" class="form-control form-control-sm" placeholder="Filtrar por cidade" />
            </div>
            <div class="col-md-4">
              <input v-model="filterNeighborhood" class="form-control form-control-sm" placeholder="Filtrar por bairro" />
            </div>
          </div>
      </div>
      <div class="admin-card">
        <div v-if="loading" class="text-muted">Carregando...</div>
        <div v-else class="table-responsive">
          <table class="table table-sm">
            <thead>
              <tr>
                <th>Título</th>
                <th>Cidade</th>
                <th>Bairro</th>
                <th>Valor</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="p in filtered" :key="p.id" @contextmenu.prevent.stop="openMenu($event, p)">
                <td>{{ p.title || p.name || '-' }}</td>
                <td>{{ p.city || '-' }}</td>
                <td>{{ p.neighborhood || '-' }}</td>
                <td>{{ p.price ? formatCurrency(p.price) : '-' }}</td>
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
const query = ref('')

// REPLACED: filtro único -> múltiplos filtros reativos
const filterTitle = ref('')
const filterType = ref('')
const filterCity = ref('')
const filterNeighborhood = ref('')
const filterMinPrice = ref('')
const filterMaxPrice = ref('')

// NEW: controla exibição dos filtros avançados (preços)
const showAdvanced = ref(false)
const toggleAdvanced = () => { showAdvanced.value = !showAdvanced.value }

const fetchRecords = async () => {
  loading.value = true
  try {
    const res = await fetch('/properties.json', { credentials: 'same-origin' })
    if (res.ok) records.value = await res.json()
    else records.value = []
  } catch (e) { records.value = [] }
  loading.value = false
}

onMounted(fetchRecords)

// filtered agora aplica todos os filtros
const filtered = computed(() => {
  const list = records.value || []
  const t = String(filterTitle.value || '').trim().toLowerCase()
  const ty = String(filterType.value || '').trim().toLowerCase()
  const c = String(filterCity.value || '').trim().toLowerCase()
  const n = String(filterNeighborhood.value || '').trim().toLowerCase()
  const min = Number(String(filterMinPrice.value || '').replace(/[^\d.-]/g, '') || NaN)
  const max = Number(String(filterMaxPrice.value || '').replace(/[^\d.-]/g, '') || NaN)

  return list.filter(r => {
    // strings: se o filtro estiver vazio, aceita; caso contrário verifica includes
    if (t && !String(r.title || r.name || '').toLowerCase().includes(t)) return false
    if (ty && !String(r.property_type || '').toLowerCase().includes(ty)) return false
    if (c && !String(r.city || '').toLowerCase().includes(c)) return false
    if (n && !String(r.neighborhood || '').toLowerCase().includes(n)) return false

    // preço: tenta normalizar r.price para número
    const price = (() => {
      if (r.price == null) return NaN
      const num = Number(r.price)
      if (!isNaN(num)) return num
      // remove símbolos e formatação comum
      const cleaned = String(r.price).replace(/[^\d.-]/g, '')
      return Number(cleaned)
    })()

    if (!isNaN(min) && !isNaN(price) && price < min) return false
    if (!isNaN(max) && !isNaN(price) && price > max) return false

    return true
  })
})

const formatCurrency = (v) => {
  try { return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(Number(v)) } catch(e) { return v }
}

// --- NOVO/ATUALIZADO: menu contextual agora usa viewport + teleport ---
const menuVisible = ref(false)
const menuX = ref(0)
const menuY = ref(0)
const menuRecord = ref(null)

const openMenu = async (e, rec) => {
  // posição inicial no cursor (viewport)
  const initialX = Math.max(8, e.clientX || 0)
  const initialY = Math.max(8, e.clientY || 0)

  menuRecord.value = rec
  menuX.value = initialX
  menuY.value = initialY
  menuVisible.value = true

  // espera o menu ser renderizado no body para medir e ajustar overflow da viewport
  await nextTick()
  const menuEl = document.querySelector('.context-menu')
  if (menuEl) {
    const mw = menuEl.offsetWidth
    const mh = menuEl.offsetHeight
    const margin = 8
    const vw = window.innerWidth
    const vh = window.innerHeight

    // preferência: abrir no canto inferior-esquerdo do cursor (i.e., top/left = cursor)
    // ajustar se ultrapassar direita/embaixo da viewport
    if (menuX.value + mw + margin > vw) {
      menuX.value = Math.max(margin, vw - mw - margin)
    }
    if (menuY.value + mh + margin > vh) {
      menuY.value = Math.max(margin, vh - mh - margin)
    }
  }
}

const closeMenu = () => {
  menuVisible.value = false
  menuRecord.value = null
}

const onGlobalClick = (ev) => {
  // fechar quando clicar fora do menu
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
  router.push({ name: 'properties-show', params: { id: rec.id } }).catch(()=>{})
  closeMenu()
}
const editRecord = (rec) => {
  if (!rec) return
  // tenta rota nomeada, fallback para path
  router.push({ name: 'properties-edit', params: { id: rec.id } }).catch(()=>{
    router.push({ path: `/properties/${rec.id}/edit` }).catch(()=>{})
  })
  closeMenu()
}
const deleteRecord = async (rec) => {
  if (!rec) return
  const label = rec.title || rec.name || `#${rec.id}`
  if (!confirm(`Confirmar exclusão de "${label}"?`)) { closeMenu(); return }
  try {
    const res = await fetch(`/properties/${rec.id}`, { method: 'DELETE', credentials: 'same-origin' })
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
// --- fim menu contextual ---
</script>

<style scoped>
/* modern minimal admin styles (aligned to navbar container) */
.admin-panel { padding: 1.25rem 0 2.5rem; background: transparent; }

/* keep content constrained with same container as navbar */
.container {
  max-width: 1140px; /* matches Bootstrap container wide breakpoint */
  margin: 0 auto;
  padding-left: 24px;
  padding-right: 24px;
}

/* card */
.admin-card {
  background: #ffffff;
  border-radius: 14px;
  box-shadow: 0 10px 30px rgba(15, 35, 77, 0.06);
  border: 1px solid rgba(15,35,77,0.06);
  overflow: hidden;
  position: relative; /* necessário para posicionar o menu contextual corretamente */
}

/* toolbar */
.admin-toolbar { margin-bottom: 12px; align-items: center; gap: 12px; }
.admin-toolbar h3 { margin: 0; font-weight: 600; color: #0f254d; font-size: 1.25rem; }

/* search field - pill style */
.search-wrapper { position: relative; min-width: 260px; }
.search-wrapper .search-icon { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: rgba(15,35,77,0.28); font-size: 0.9rem; }
.search-wrapper input {
  padding: 10px 12px 10px 36px;
  border-radius: 999px;
  border: 1px solid rgba(15,35,77,0.06);
  background: #f6f8fb;
  box-shadow: none;
  min-width: 220px;
}

/* add button - minimal rounded */
.add-btn {
  background: #4ADE80;
  color: #08203a;
  border: 0;
  font-weight: 600;
  border-radius: 999px;
  padding: 0.42rem 0.9rem;
  box-shadow: 0 6px 18px rgba(10,20,30,0.06);
}

/* table - minimal header and soft separators */
.table {
  border-collapse: separate;
  border-spacing: 0;
  width: 100%;
}
.table thead th {
  background: transparent;
  color: rgba(15,35,77,0.85);
  font-weight: 700;
  font-size: 0.9rem;
  border-bottom: 1px solid rgba(15,35,77,0.06);
  padding: 12px 12px;
}
.table tbody td {
  padding: 12px;
  color: #1f2d47;
  border-bottom: 1px solid rgba(15,35,77,0.04);
}

.admin-card .table tbody tr:nth-child(odd) td {
  background-color: #ffffff;
}
.admin-card .table tbody tr:nth-child(even) td {
  background-color: #f6f8fb;
}
.admin-card .table tbody tr:hover td {
  background-color: rgba(26,46,102,0.06) !important;
}

/* zebra striping: linhas alternadas para melhor leitura */
.table tbody tr:nth-child(odd) {
  background-color: #ffffff;
}
.table tbody tr:nth-child(even) {
  background-color: #f6f8fb;
}

/* hover deve prevalecer sobre o striping */
.table tbody tr:hover {
  background-color: rgba(26,46,102,0.06);
}

/* menu contextual */
.context-menu {
  position: fixed;
  min-width: 140px;
  background: #ffffff;
  border-radius: 8px;
  box-shadow: 0 12px 30px rgba(15,35,77,0.18);
  border: 1px solid rgba(15,35,77,0.06);
  z-index: 9999; /* alto para ficar na frente */
  padding: 6px;
  transform-origin: top left;
}
.context-menu ul {
  list-style: none;
  margin: 0;
  padding: 4px 0;
}
.context-menu li {
  padding: 8px 12px;
  cursor: pointer;
  color: #0f254d;
  font-size: 0.95rem;
  border-radius: 6px;
}
.context-menu li:hover { background: rgba(15,35,77,0.06); }
.context-menu li.danger { color: #c92a2a; }

/* small layout tweaks for filters row */
.filters-row .form-control { height: 36px; }

/* CHANGED: filtros mais arredondados e com sombra/feedback moderno */
.filters-row .form-control {
  height: 42px;
  border-radius: 999px;           /* fully pill-shaped */
  padding: 10px 18px;
  border: 1px solid rgba(15,35,77,0.06);
  background: #f6f8fb;
  box-shadow: 0 6px 18px rgba(15,35,77,0.04);
  transition: box-shadow 150ms ease, transform 120ms ease;
  min-height: 42px;
}

/* botão de toggle dos filtros */
.filters-toggle {
  border-radius: 999px;
  padding: 8px 14px;
  background: #ffffff;
  border: 1px solid rgba(15,35,77,0.06);
  box-shadow: 0 6px 18px rgba(15,35,77,0.04);
  color: #0f254d;
  transition: transform .12s ease, box-shadow .12s ease;
}
.filters-toggle:hover { transform: translateY(-2px); box-shadow: 0 10px 22px rgba(15,35,77,0.06); }

/* linha avançada (preços) também pill-shaped */
.filters-advanced .form-control {
  height: 42px;
  border-radius: 999px;
  padding: 10px 14px;
  border: 1px solid rgba(15,35,77,0.06);
  background: #f6f8fb;
  box-shadow: 0 6px 18px rgba(15,35,77,0.03);
}

.add-btn:hover,
.add-btn:focus {
  background: #4ADE80 !important;
  color: #08203a !important;
  transform: translateY(-2px);
  box-shadow: 0 10px 22px rgba(10,20,30,0.08);
}

/* transição simples para abrir/fechar filtros */
.fade-slide-enter-active, .fade-slide-leave-active {
  transition: opacity .18s ease, transform .18s ease;
}
.fade-slide-enter-from, .fade-slide-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}

/* responsividade: em telas pequenas, empilha inputs */
@media (max-width: 576px) {
  .filters-row .col-md-3,
  .filters-row .col-md-2,
  .filters-row .col-md-1,
  .filters-advanced .col-md-2 {
    flex: 0 0 100%;
    max-width: 100%;
  }
}

/* responsive tweaks */
@media (max-width: 768px) {
  .container { padding-left: 16px; padding-right: 16px; }
  .search-wrapper { min-width: 100%; width: 100%; }
  .admin-toolbar { flex-direction: column; align-items: stretch; gap: 8px; }
  .add-btn { width: 100%; }
}
</style>
