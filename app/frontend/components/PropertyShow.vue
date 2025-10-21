<template>
  <div class="container py-4">
    <div v-if="loading" class="text-center">Carregando...</div>
    <div v-else-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-else class="card shadow-sm">
      <div class="row g-0">
        <div class="col-md-5">
          <!-- imagem/placeholder -->
          <div class="bg-secondary text-white d-flex align-items-center justify-content-center" style="height:100%; min-height:220px;">
            <div>
              <div class="h5 mb-1">Imagem do imóvel</div>
              <div class="small">(adicione fotos com ActiveStorage/attachments)</div>
            </div>
          </div>
        </div>
        <div class="col-md-7">
          <div class="card-body">
            <h3 class="card-title">{{ property.title }}</h3>
            <p class="text-muted mb-1">{{ property.city }}, {{ property.state }}</p>
            <p class="h4 text-primary mb-3">{{ formatPrice(property.price) }}</p>

            <p v-if="property.description" class="mb-3">{{ property.description }}</p>

            <ul class="list-inline mb-3 small">
              <li class="list-inline-item me-3"><strong>Quartos:</strong> {{ property.bedrooms }}</li>
              <li class="list-inline-item me-3"><strong>Banheiros:</strong> {{ property.bathrooms }}</li>
              <li class="list-inline-item me-3"><strong>Vagas:</strong> {{ property.parking_spaces }}</li>
              <li class="list-inline-item"><strong>Área:</strong> {{ property.area || '—' }} m²</li>
            </ul>

            <p class="small text-muted mb-1">Anunciante: {{ property.agent_name || '—' }}</p>
            <p class="small text-muted">Endereço: {{ property.address }}, {{ property.neighborhood }} — {{ property.zip_code }}</p>

            <div class="mt-3">
              <router-link :to="{ name: 'properties-edit', params: { id: property.id } }" v-if="canEdit" class="btn btn-secondary me-2">Editar</router-link>
              <router-link to="/" class="btn btn-outline-primary">Voltar</router-link>

              <!-- Agendar visita: botão visível para qualquer pessoa -->
              <button @click="handleScheduleClick" class="btn btn-primary ms-2">
                {{ showScheduler ? 'Cancelar' : 'Agendar visita' }}
              </button>
            </div>

            <!-- scheduler form -->
            <div v-if="showScheduler" class="mt-3">
              <div class="mb-2">
                <label class="form-label small">Data e hora</label>
                <input type="datetime-local" v-model="scheduledAt" class="form-control" />
              </div>
              <div class="mb-2">
                <label class="form-label small">Observações (opcional)</label>
                <textarea v-model="notes" class="form-control" rows="2"></textarea>
              </div>

              <div class="d-flex align-items-center">
                <button class="btn btn-success me-2" :disabled="submitting" @click="schedule">
                  {{ submitting ? 'Enviando...' : 'Confirmar agendamento' }}
                </button>
                <div v-if="formError" class="text-danger small">{{ formError }}</div>
                <div v-if="successMessage" class="text-success small">{{ successMessage }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const id = route.params.id

const property = ref(null)
const loading = ref(true)
const error = ref(null)
const currentUser = ref(null)

// novos estados para agendamento
const showScheduler = ref(false)
const scheduledAt = ref('')
const notes = ref('')
const submitting = ref(false)
const formError = ref(null)
const successMessage = ref(null)

const fetchCurrent = async () => {
  try {
    const res = await fetch('/current_user')
    if (res.ok) currentUser.value = await res.json()
  } catch (e) {}
}

const load = async () => {
  loading.value = true
  try {
    const res = await fetch(`/properties/${id}.json`)
    if (!res.ok) throw new Error('Imóvel não encontrado')
    property.value = await res.json()
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  await fetchCurrent()
  await load()

  if (route.query.show_schedule) {
    if (currentUser.value) {
      showScheduler.value = true
    }
    // se não estiver logado, normalmente veio do redirect após login; fetchCurrent cobriu esse caso
  }
})

const formatPrice = (v) => {
  if (v == null) return '—'
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(Number(v))
}

const canEdit = computed(() => {
  if (!currentUser.value || !property.value) return false
  const role = currentUser.value.role
  if (role === 'admin' || role === 2) return true
  return role === 'agent' && currentUser.value.id === property.value.agent_id
})

// util para obter csrf token
const csrfToken = () => {
  const m = document.querySelector('meta[name="csrf-token"]')
  return m ? m.getAttribute('content') : ''
}

// novo: botão visível para todos; decide ação conforme login
const handleScheduleClick = () => {
  if (currentUser.value) {
    showScheduler.value = !showScheduler.value
    return
  }
  // build return path that forces the scheduler to open after login
  const path = window.location.pathname + window.location.search
  const separator = path.includes('?') ? '&' : '?'
  const returnTo = `${path}${separator}show_schedule=1`

  // save desired return path in localStorage so the SPA can redirect after Devise returns to the SPA
  try {
    localStorage.setItem('after_sign_in', returnTo)
  } catch (e) {
    // ignore storage errors
  }

  // redirect to Devise login page (no query param required)
  window.location.href = '/users/sign_in'
}

const schedule = async () => {
  formError.value = null
  successMessage.value = null
  if (!scheduledAt.value) {
    formError.value = 'Escolha data e hora da visita.'
    return
  }
  submitting.value = true
  try {
    // converter datetime-local (YYYY-MM-DDTHH:MM) para ISO com timezone UTC
    const iso = new Date(scheduledAt.value).toISOString()
    const payload = {
      visit: {
        property_id: property.value.id,
        agent_id: property.value.agent_id,
        scheduled_at: iso,
        notes: notes.value
      }
    }
    const res = await fetch('/visits.json', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken()
      },
      body: JSON.stringify(payload),
      credentials: 'same-origin'
    })
    if (res.ok) {
      const data = await res.json()
      successMessage.value = 'Visita agendada com sucesso.'
      showScheduler.value = false
      // opcional: limpar form
      scheduledAt.value = ''
      notes.value = ''
    } else {
      const err = await res.json().catch(() => null)
      formError.value = (err && (err.error || (err.errors && err.errors.join(', ')))) || 'Erro ao agendar.'
    }
  } catch (e) {
    formError.value = e.message || 'Erro ao agendar.'
  } finally {
    submitting.value = false
  }
}

// permite que o botão seja sempre exibido (visível para qualquer pessoa)
const canSchedule = computed(() => true)
</script>

<style scoped>
.card { overflow: hidden; }
</style>
