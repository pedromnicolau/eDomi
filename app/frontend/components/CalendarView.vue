<template>
  <div class="container py-4">
    <div class="d-flex align-items-center justify-content-between mb-3">
      <div class="d-flex align-items-center gap-2">
        <button class="btn btn-outline-secondary" @click="prevMonth" type="button">‹</button>
        <div class="fw-bold">{{ monthLabel }}</div>
        <button class="btn btn-outline-secondary" @click="nextMonth" type="button">›</button>
      </div>
      <div>
        <button class="btn btn-sm btn-outline-primary" @click="today">Hoje</button>
      </div>
    </div>

    <div class="calendar-grid headings">
      <div v-for="(w, idx) in weekDays" :key="idx" class="calendar-cell heading">{{ w }}</div>
    </div>

    <div class="calendar-grid days">
      <div
        v-for="(cell, idx) in cells"
        :key="idx"
        class="calendar-cell day-cell"
        :class="{
          empty: !cell.date,
          'has-visits': cell && cell.visits && cell.visits.length > 0,
          today: cell && cell.isToday,
          selected: cell && cell.date === selectedDate
        }"
        @click="cell.date && openDay(cell.date)"
      >
        <div class="day-number">{{ cell.date ? cell.day : '' }}</div>

        <!-- mostra quantidade e links rápidos -->
        <div v-if="cell && cell.visits && cell.visits.length" class="visits-rect">
          <div class="small fw-semibold text-danger mb-1">
            {{ cell.visits.length }} visita{{ cell.visits.length > 1 ? 's' : '' }}
          </div>

          <div v-for="(v,i) in cell.visits.slice(0,2)" :key="i" class="visit-line">
            <div class="d-flex align-items-center justify-content-between">
              <div>
                <router-link
                  v-if="v.property_id"
                  :to="`/properties/${v.property_id}`"
                  class="text-decoration-none text-dark"
                >
                  <span class="visit-time">{{ formatTime(v.scheduled_at) }}</span>
                  <span class="visit-prop">— {{ v.property_title || ('Imóvel #' + v.property_id) }}</span>
                </router-link>

                <span v-else class="text-muted small">
                  {{ formatTime(v.scheduled_at) }} — {{ v.property_title || 'Imóvel desconhecido' }}
                </span>
              </div>
              <!-- status badge -->
              <div>
                <span
                  class="small badge-status"
                  :class="v.status === 'pending' ? 'badge-pending' : (v.status === 'confirmed' ? 'badge-confirmed' : '')"
                >
                  {{ v.status === 'pending' ? 'Pendente' : (v.status === 'confirmed' ? 'Confirmada' : '') }}
                </span>
              </div>
            </div>
          </div>

          <div v-if="cell.visits.length > 2" class="more small">+{{ cell.visits.length - 2 }} mais...</div>
        </div>
      </div>
    </div>

    <div v-if="selectedDate" class="mt-4">
      <h5 class="mb-3">
        Visitas em {{ selectedDate }}
        <span class="badge bg-primary ms-2">{{ visitsForSelectedDate.length }}</span>
      </h5>

      <ul class="list-group">
        <li
          v-for="v in visitsForSelectedDate"
          :key="v.id"
          class="list-group-item d-flex justify-content-between align-items-start"
        >
          <div>
            <router-link
              v-if="v.property_id"
              :to="`/properties/${v.property_id}`"
              class="fw-semibold text-decoration-none text-primary"
            >
              {{ v.property_title || ('Imóvel #' + v.property_id) }}
            </router-link>

            <div v-else class="fw-semibold text-muted">
              {{ v.property_title || ('Imóvel desconhecido') }}
            </div>

            <div class="small text-muted">
              {{ formatTime(v.scheduled_at) }} — {{ v.notes || '' }}
            </div>
          </div>

          <div class="small text-end text-muted">
            <div>{{ v.buyer_name || v.buyer_email || '' }}</div>
            <div>{{ v.agent_name || v.agent_email || '' }}</div>

            <!-- Ações do anunciante (aceitar / recusar) -->
            <div v-if="canManageVisit(v)" class="mt-2 d-flex gap-2 justify-content-end">
              <button v-if="v.status === 'pending'" class="btn btn-sm btn-success" @click="acceptVisit(v.id)" :disabled="actionLoading[v.id]">Aceitar</button>
              <button v-if="v.status === 'pending'" class="btn btn-sm btn-outline-danger" @click="rejectVisit(v.id)" :disabled="actionLoading[v.id]">Recusar</button>
            </div>
          </div>
        </li>

        <li
          v-if="visitsForSelectedDate.length === 0"
          class="list-group-item small text-muted text-center"
        >
          Nenhuma visita neste dia.
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const todayDate = new Date()
const year = ref(todayDate.getFullYear())
const month = ref(todayDate.getMonth()) // 0..11

const visits = ref([])
const visitsByDate = ref({}) // { 'YYYY-MM-DD': [visit, ...] }

const selectedDate = ref('')

const weekDays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']

const pad = (n) => String(n).padStart(2, '0')
const toKey = (d) => `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}`

// Normaliza vários formatos de scheduled_at para a chave local YYYY-MM-DD
const parseToDate = (iso) => {
  if (!iso) return null
  const s = String(iso).trim()
  const m = s.match(/^(\d{4}-\d{2}-\d{2})/)
  if (m) {
    const parts = m[1].split('-').map(Number)
    return new Date(parts[0], parts[1] - 1, parts[2])
  }
  const normalized = s.replace(/^(\d{4}-\d{2}-\d{2})\s+/, '$1T')
  const d = new Date(normalized)
  if (!isNaN(d)) return d
  const d2 = new Date(s)
  return isNaN(d2) ? null : d2
}

const toKeyFromISO = (iso) => {
  const d = parseToDate(iso)
  if (!d) return ''
  return toKey(d)
}

const monthLabel = computed(() => {
  const d = new Date(year.value, month.value, 1)
  return d.toLocaleString('pt-BR', { month: 'long', year: 'numeric' })
})

const cells = computed(() => {
  const first = new Date(year.value, month.value, 1)
  const startWeekday = first.getDay()
  const last = new Date(year.value, month.value + 1, 0)
  const daysInMonth = last.getDate()

  const cellsArr = []
  for (let i = 0; i < startWeekday; i++) cellsArr.push({ date: null })
  for (let d = 1; d <= daysInMonth; d++) {
    const dt = new Date(year.value, month.value, d)
    const key = toKey(dt)
    cellsArr.push({
      date: key,
      day: d,
      visits: visitsByDate.value[key] || []
    })
  }
  while (cellsArr.length % 7 !== 0) cellsArr.push({ date: null })
  while (cellsArr.length < 42) cellsArr.push({ date: null })
  return cellsArr
})

const visitsForSelectedDate = computed(() => {
  if (!selectedDate.value) return []
  const arr = visitsByDate.value[selectedDate.value] || []
  return arr.slice().sort((a, b) => {
    const ta = parseToDate(a.scheduled_at) || new Date(0)
    const tb = parseToDate(b.scheduled_at) || new Date(0)
    return ta - tb
  })
})

const fetchVisits = async () => {
  try {
    const res = await fetch('/visits.json', { credentials: 'same-origin' })
    if (!res.ok) {
      console.warn('fetchVisits: /visits.json respondeu com status', res.status)
      visits.value = []
      visitsByDate.value = {}
      return
    }
    const data = await res.json()
    visits.value = Array.isArray(data) ? data : []
    // debug: mostrar quantas visitas vieram
    console.debug('fetchVisits -> visits count:', visits.value.length)

    const map = {}
    for (const v of visits.value) {
      const raw = v.scheduled_at || v.scheduledAt || v.scheduled || v.created_at || v.createdAt
      const k = toKeyFromISO(raw)
      if (!k) {
        // se não conseguiu parse, tente com created_at fallback
        const fallbackKey = toKeyFromISO(v.created_at || v.createdAt)
        if (!fallbackKey) {
          console.warn('visit sem data válida:', v)
          continue
        } else {
          if (!map[fallbackKey]) map[fallbackKey] = []
          map[fallbackKey].push(v)
        }
      } else {
        if (!map[k]) map[k] = []
        map[k].push(v)
      }
    }

    // ordenar cada dia por horário
    for (const k of Object.keys(map)) {
      map[k].sort((a, b) => {
        const ta = parseToDate(a.scheduled_at) || new Date(0)
        const tb = parseToDate(b.scheduled_at) || new Date(0)
        return ta - tb
      })
    }

    visitsByDate.value = map

    // se a rota trouxe query.date, manter seleção visível
    const qdate = route.query.date
    if (qdate && typeof qdate === 'string' && toKeyFromISO(qdate)) {
      selectedDate.value = qdate.split('T')[0].split(' ')[0]
    }
  } catch (e) {
    console.error('fetchVisits erro', e)
    visits.value = []
    visitsByDate.value = {}
  }
}

const openDay = (dateKey) => {
  selectedDate.value = dateKey
}

const formatTime = (iso) => {
  try {
    const d = new Date(iso)
    if (isNaN(d)) return iso || ''
    return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
  } catch (e) {
    return iso
  }
}

const prevMonth = () => {
  if (month.value === 0) { month.value = 11; year.value -= 1 } else { month.value -= 1 }
}
const nextMonth = () => {
  if (month.value === 11) { month.value = 0; year.value += 1 } else { month.value += 1 }
}
const today = () => {
  const d = new Date()
  year.value = d.getFullYear()
  month.value = d.getMonth()
  selectedDate.value = toKey(d)
}

const currentUser = ref(null)
const actionLoading = ref({}) // map visitId -> bool

const fetchCurrentUser = async () => {
  try {
    const res = await fetch('/current_user', { credentials: 'same-origin' })
    if (res.ok) {
      currentUser.value = await res.json()
    } else {
      currentUser.value = null
    }
  } catch (e) {
    currentUser.value = null
  }
}

// helper: checa se o usuário atual pode gerenciar (aceitar/recusar) a visita
const isAdmin = (u) => {
  if (!u) return false
  const r = u.role
  return r === 'admin' || r === '2' || r === 2
}
const canManageVisit = (v) => {
  if (!currentUser.value) return false
  if (isAdmin(currentUser.value)) return true
  return Number(currentUser.value.id) === Number(v.agent_id)
}

// atualiza uma visita em visitsByDate por id (aplica updater fn)
const updateVisitInMap = (visitId, updater) => {
  for (const k of Object.keys(visitsByDate.value)) {
    let changed = false
    visitsByDate.value[k] = visitsByDate.value[k].map(v => {
      if (Number(v.id) === Number(visitId)) {
        changed = true
        return updater(Object.assign({}, v))
      }
      return v
    }).filter(Boolean)
    // se removed (updater returned null), removido via filter
    if (changed) {
      // trigger reactivity by reassigning object
      visitsByDate.value = Object.assign({}, visitsByDate.value)
      break
    }
  }
}

const acceptVisit = async (id) => {
  actionLoading.value[id] = true
  try {
    const res = await fetch(`/visits/${id}/accept`, {
      method: 'PATCH',
      headers: { 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '' },
      credentials: 'same-origin'
    })
    if (res.ok) {
      // atualizar status local para confirmed
      updateVisitInMap(id, (v) => { v.status = 'confirmed'; return v })
    } else {
      console.warn('acceptVisit failed', res.status)
    }
  } catch (e) {
    console.error('acceptVisit error', e)
  } finally {
    actionLoading.value[id] = false
  }
}

const rejectVisit = async (id) => {
  actionLoading.value[id] = true
  try {
    const res = await fetch(`/visits/${id}/reject`, {
      method: 'PATCH',
      headers: { 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '' },
      credentials: 'same-origin'
    })
    if (res.ok) {
      // remover visita do map (vai desaparecer do calendário)
      updateVisitInMap(id, (v) => null)
    } else {
      console.warn('rejectVisit failed', res.status)
    }
  } catch (e) {
    console.error('rejectVisit error', e)
  } finally {
    actionLoading.value[id] = false
  }
}

onMounted(async () => {
  // tenta inicializar selectedDate a partir da query string (rota /calendar?date=YYYY-MM-DD)
  const qdate = route.query.date
  if (qdate && typeof qdate === 'string') {
    const parts = String(qdate).split('-')
    if (parts.length === 3) {
      year.value = Number(parts[0]) || year.value
      month.value = (Number(parts[1]) - 1) || month.value
      selectedDate.value = `${String(parts[0]).padStart(4,'0')}-${pad(Number(parts[1]))}-${pad(Number(parts[2]))}`
    } else {
      const k = toKeyFromISO(qdate)
      if (k) selectedDate.value = k
    }
  }

  await Promise.all([ fetchCurrentUser(), fetchVisits() ])
})
</script>

<style scoped>
.calendar-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 6px; }
.calendar-cell { background: #fff; border-radius: 6px; padding: 8px; min-height: 72px; box-shadow: 0 1px 2px rgba(0,0,0,0.04); }
.headings .calendar-cell { background: transparent; box-shadow: none; padding: 6px 8px; color: #666; text-align: center; font-weight: 600; }
.day-cell { cursor: pointer; position: relative; }
.day-cell.empty { background: transparent; box-shadow: none; cursor: default; }
.day-number { font-weight: 600; }
.has-visits { border: 1px solid rgba(26,46,102,0.12); }
.dot-list { margin-top: 6px; display:flex; gap:4px; flex-wrap:wrap; }
.dot { width:8px; height:8px; border-radius:50%; background:#1A2E66; display:inline-block; }
.today { outline: 2px solid #4ADE80; }
.day-cell.selected {
  outline: 3px solid #4ADE80;
  z-index: 2;
}

.visits-rect {
  margin-top: 6px;
  background: rgba(220, 53, 69, 0.06);
  border: 1px solid rgba(220,53,69,0.12);
  border-radius: 6px;
  padding: 6px;
  max-height: 56px;
  overflow: hidden;
}
.visit-line {
  font-size: 12px;
  color: #b02a37;
  white-space: nowrap;
  text-overflow: ellipsis;
  overflow: hidden;
  display: block;
}
.visit-time { font-weight: 600; margin-right: 6px; }
.more { text-align: right; color: #8b0000; }
.badge-status { display:inline-block; padding: 2px 8px; border-radius: 999px; font-weight:600; font-size:0.7rem; }
.badge-pending { background: #facc15; color: #1a1a1a; }   /* amarelo */
.badge-confirmed { background: #10b981; color: #fff; }    /* verde */
</style>
