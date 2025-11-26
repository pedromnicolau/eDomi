<template>
  <div class="container py-4">
    <div v-if="loading" class="text-center">Carregando...</div>
    <div v-else-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-else class="card shadow-sm">
      <!-- GALERIA -->
      <div class="property-gallery p-3" @mouseenter="stopAutoAdvance" @mouseleave="startAutoAdvance">
        <div class="main-photo mb-2 position-relative">
          <img
            v-if="photos.length"
            :src="photos[selectedPhoto]"
            alt="foto principal"
            class="img-fluid w-100"
            @click="openLightbox"
          />
          <div v-else class="bg-secondary text-white d-flex align-items-center justify-content-center" style="height:320px;">
            <div>
              <div class="h5 mb-1">Imagem do imóvel</div>
              <div class="small">(adicione fotos com ActiveStorage/attachments)</div>
            </div>
          </div>

          <button v-if="photos.length" class="nav-arrow left" @click.stop="prevPhoto" aria-label="Anterior">&lsaquo;</button>
          <button v-if="photos.length" class="nav-arrow right" @click.stop="nextPhoto" aria-label="Próximo">&rsaquo;</button>
        </div>

        <div v-if="photos.length" class="thumbs d-flex flex-row flex-wrap gap-2">
          <img
            v-for="(p, idx) in photos"
            :key="p + idx"
            :src="p"
            @click="selectedPhoto = idx"
            :class="['thumb', { active: idx === selectedPhoto }]"
            :alt="`thumb-${idx}`"
          />
        </div>
      </div>

      <!-- INFORMAÇÕES -->
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
          <button @click="handleScheduleClick" class="btn btn-primary ms-2">
            {{ showScheduler ? 'Cancelar' : 'Agendar visita' }}
          </button>
          <a :href="whatsappLink" target="_blank" rel="noopener" class="btn btn-success ms-2">Contatar via WhatsApp</a>
        </div>

        <!-- MAPA -->
        <div v-if="property.zip_code" class="mt-4">
          <div class="d-flex align-items-center justify-content-between mb-2">
            <h5 class="mb-0">Localização</h5>
            <a :href="mapsDirectLink" target="_blank" rel="noopener" class="small">Abrir no Google Maps</a>
          </div>
          <div class="map-embed-wrapper">
            <iframe
              :src="mapsEmbedUrl"
              width="100%"
              height="360"
              style="border:0;"
              allowfullscreen=""
              loading="lazy"
              referrerpolicy="no-referrer-when-downgrade"
            ></iframe>
          </div>
          <div class="small text-muted mt-1">CEP: {{ property.zip_code }}</div>
        </div>

        <!-- SCHEDULER -->
        <div v-if="showScheduler" class="mt-3 p-3 border rounded shadow-sm bg-white">
          <!-- Data -->
          <div class="mb-2">
            <label class="form-label small">Data da visita</label>
            <input
              type="date"
              v-model="scheduledDate"
              class="form-control"
              :min="minDate"
              :class="{ 'is-invalid': dateError }"
            />
            <div v-if="dateError" class="invalid-feedback small">{{ dateError }}</div>
          </div>

          <!-- Hora -->
          <div class="mb-2">
            <label class="form-label small">Hora da visita</label>
            <input
              type="time"
              v-model="scheduledTime"
              class="form-control"
              :class="{ 'is-invalid': timeError }"
            />
            <div v-if="timeError" class="invalid-feedback small">{{ timeError }}</div>
          </div>

          <!-- Observações -->
          <div class="mb-2">
            <label class="form-label small">Observações (opcional)</label>
            <textarea v-model="notes" class="form-control" rows="2"></textarea>
          </div>

          <!-- Botão -->
          <div class="d-flex align-items-center">
            <button
              class="btn btn-success me-2"
              :disabled="submitting || dateError || timeError"
              @click="schedule"
            >
              {{ submitting ? 'Enviando...' : 'Confirmar agendamento' }}
            </button>
            <div v-if="formError" class="text-danger small">{{ formError }}</div>
            <div v-if="successMessage" class="text-success small">{{ successMessage }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- LIGHTBOX modal -->
  <div v-if="lightboxOpen" class="lightbox-backdrop" @click.self="closeLightbox">
    <button class="lightbox-close btn-close" @click="closeLightbox" aria-label="Fechar"></button>
    <button class="lightbox-arrow left" @click.stop="prevPhoto" aria-label="Anterior">&#10094;</button>
    <div class="lightbox-content">
      <img :src="photos[selectedPhoto]" alt="lightbox photo" class="lightbox-img" />
      <div class="lightbox-caption small text-white mt-2">{{ selectedPhoto + 1 }} / {{ photos.length }}</div>
    </div>
    <button class="lightbox-arrow right" @click.stop="nextPhoto" aria-label="Próximo">&#10095;</button>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch, onBeforeUnmount, nextTick } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const id = route.params.id

// reactive state
const property = ref(null)
const loading = ref(true)
const error = ref(null)
const currentUser = ref(null)

// scheduler state
const showScheduler = ref(false)
const scheduledDate = ref('')
const scheduledTime = ref('')
const notes = ref('')
const submitting = ref(false)
const formError = ref(null)
const successMessage = ref(null)

// whatsapp link
const whatsappLink = computed(() => {
  if (!property.value) return '#'
  const phone = '5513978252727'
  const text = encodeURIComponent(`Olá, tenho interesse no imóvel "${property.value.title}"`)
  return `https://wa.me/${phone}?text=${text}`
})

// google maps links by CEP
const mapsQuery = computed(() => {
  if (!property.value || !property.value.zip_code) return ''
  // Use only the CEP to avoid mismatched addresses; include country for accuracy
  return encodeURIComponent(`${property.value.zip_code} Brasil`)
})
const mapsEmbedUrl = computed(() => {
  if (!mapsQuery.value) return 'about:blank'
  // Public embed that doesn't require API key
  return `https://www.google.com/maps?q=${mapsQuery.value}&hl=pt-BR&z=15&output=embed`
})
const mapsDirectLink = computed(() => {
  if (!mapsQuery.value) return '#'
  return `https://www.google.com/maps?q=${mapsQuery.value}`
})

// gallery / lightbox / carousel
const selectedPhoto = ref(0)
const photos = computed(() => (property.value && property.value.photos_urls) ? property.value.photos_urls : [])
const lightboxOpen = ref(false)
let autoAdvanceInterval = ref(null)

watch(property, () => {
  selectedPhoto.value = 0
  stopAutoAdvance()
  nextTick(() => startAutoAdvance())
})

onBeforeUnmount(() => {
  stopAutoAdvance()
  removeKeyListeners()
})

// fetch user
const fetchCurrent = async () => {
  try {
    const res = await fetch('/current_user')
    if (res.ok) currentUser.value = await res.json()
  } catch {}
}

// load property
const load = async () => {
  loading.value = true
  try {
    const res = await fetch(`/properties/${id}.json`)
    if (!res.ok) throw new Error('Imóvel não encontrado')
    property.value = await res.json()
    selectedPhoto.value = 0
    startAutoAdvance()
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  await fetchCurrent()
  await load()

  if (route.query.show_schedule && currentUser.value) {
    showScheduler.value = true
  }
})

// carousel
const startAutoAdvance = () => {
  stopAutoAdvance()
  // don't start auto-advance while lightbox is open
  if (lightboxOpen.value) return
  if (!photos.value || photos.value.length <= 1) return
  autoAdvanceInterval.value = setInterval(() => nextPhoto(), 5000)
}
const stopAutoAdvance = () => {
  if (autoAdvanceInterval.value) {
    clearInterval(autoAdvanceInterval.value)
    autoAdvanceInterval.value = null
  }
}
const prevPhoto = () => {
  if (!photos.value.length) return
  selectedPhoto.value = (selectedPhoto.value - 1 + photos.value.length) % photos.value.length
}
const nextPhoto = () => {
  if (!photos.value.length) return
  selectedPhoto.value = (selectedPhoto.value + 1) % photos.value.length
}

// lightbox
const openLightbox = () => {
  if (!photos.value.length) return
  lightboxOpen.value = true
  stopAutoAdvance()
  addKeyListeners()
}
const closeLightbox = () => {
  lightboxOpen.value = false
  removeKeyListeners()
  startAutoAdvance()
}

// keyboard navigation
const handleKeydown = (e) => {
  if (!lightboxOpen.value) return
  if (e.key === 'Escape') closeLightbox()
  if (e.key === 'ArrowLeft') prevPhoto()
  if (e.key === 'ArrowRight') nextPhoto()
}
const addKeyListeners = () => window.addEventListener('keydown', handleKeydown)
const removeKeyListeners = () => window.removeEventListener('keydown', handleKeydown)

// schedule visit
const schedule = async () => {
  formError.value = null
  successMessage.value = null

  if (!scheduledDate.value || !scheduledTime.value) {
    formError.value = 'Escolha data e hora da visita.'
    return
  }

  const scheduledAtISO = new Date(`${scheduledDate.value}T${scheduledTime.value}`).toISOString()
  submitting.value = true

  try {
    const payload = {
      visit: {
        property_id: property.value.id,
        agent_id: property.value.agent_id,
        scheduled_at: scheduledAtISO,
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
      await res.json()
      successMessage.value = 'Visita agendada com sucesso.'
      showScheduler.value = false
      scheduledDate.value = ''
      scheduledTime.value = ''
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

// helpers
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
const csrfToken = () => document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''

// handle schedule button
const handleScheduleClick = () => {
  if (currentUser.value) {
    showScheduler.value = !showScheduler.value
    return
  }
  const path = window.location.pathname + window.location.search
  const separator = path.includes('?') ? '&' : '?'
  const returnTo = `${path}${separator}show_schedule=1`
  try { localStorage.setItem('after_sign_in', returnTo) } catch {}
  window.location.href = '/users/sign_in'
}
</script>

<style scoped>
.card { overflow: hidden; }
.property-gallery { background: #fff; }
.property-gallery .main-photo img { height: 360px; object-fit: cover; border-radius: 6px; }
.nav-arrow { position: absolute; top: 50%; transform: translateY(-50%); background: rgba(26,46,102,0.65); color: #fff; border: none; width: 44px; height: 44px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; cursor: pointer; }
.nav-arrow.left { left: 12px; }
.nav-arrow.right { right: 12px; }
.nav-arrow:hover { background: rgba(26,46,102,0.85); }
.thumbs { margin-top: 0.5rem; }
.thumb { width: 96px; height: 72px; object-fit: cover; border-radius: 6px; cursor: pointer; border: 2px solid transparent; }
.thumb.active { border-color: #1A2E66; }
.thumb:hover { opacity: 0.9; transform: scale(1.02); transition: .12s; }
.lightbox-backdrop { position: fixed; inset: 0; background: rgba(0,0,0,0.85); display: flex; align-items: center; justify-content: center; z-index: 2000; padding: 1rem; }
.lightbox-content { max-width: 1100px; width: 100%; text-align: center; }
.lightbox-img { max-height: calc(100vh - 160px); width: auto; max-width: 100%; border-radius: 6px; }
.lightbox-caption { opacity: 0.9; }
.lightbox-arrow { position: fixed; top: 50%; transform: translateY(-50%); border: none; background: transparent; color: #fff; font-size: 2.5rem; padding: 0.5rem 0.8rem; cursor: pointer; z-index: 2100; }
.lightbox-arrow.left { left: 20px; }
.lightbox-arrow.right { right: 20px; }
.lightbox-close { position: fixed; top: 16px; right: 16px; z-index: 2200; background: rgba(255,255,255,0.06); color: #fff; }
@media (max-width: 576px) {
  .property-gallery .main-photo img { height: 220px; }
  .thumb { width: 64px; height: 48px; }
}
/* mapa */
.map-embed-wrapper { border-radius: 6px; overflow: hidden; box-shadow: 0 1px 2px rgba(0,0,0,0.06); }
</style>
