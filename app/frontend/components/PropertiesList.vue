<template>
  <div class="container py-4">

    <!-- novo botão 'Novo imóvel' posicionado antes do título -->
    <div class="d-flex justify-content-between align-items-center mb-3">
      <div>
        <router-link v-if="canCreate" to="/properties/new" class="btn btn-primary me-2">Novo imóvel</router-link>
      </div>
    </div>

    <!-- header com quantidade -->
    <div class="d-flex justify-content-between align-items-center mb-3">
      <div>
        <h1 class="h4 mb-0">{{ properties.length.toLocaleString() }} imóveis</h1>
        <div class="text-muted small">à venda</div>
      </div>
      <!-- opcional: filtros/ordenar -->
      <div>
        <!-- ...existing controls could go here... -->
      </div>
    </div>

    <div v-if="loading" class="text-center">Carregando...</div>
    <div v-else-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-else>
      <div v-if="properties.length === 0" class="text-muted">Nenhum imóvel encontrado.</div>
      <div class="row g-3">
        <div class="col-md-4" v-for="p in properties" :key="p.id">
          <div class="card h-100 property-card">
            <!-- imagem/carrossel no topo -->
              <div class="card-img-top position-relative overflow-hidden" style="height:220px;">
                <div v-if="p.photos_urls && p.photos_urls.length" class="h-100 w-100">
                  <router-link :to="{ name: 'properties-show', params: { id: p.id } }"><img :src="currentPhotoUrl(p.id, p)" alt="" class="w-100 h-100 object-cover" /></router-link>
                  <button class="card-arrow left" @click.stop="prevPhoto(p.id)" aria-label="Anterior">&lsaquo;</button>
                  <button class="card-arrow right" @click.stop="nextPhoto(p.id)" aria-label="Próximo">&rsaquo;</button>
                  <div class="photo-dots">
                    <span v-for="(u, i) in p.photos_urls" :key="i" :class="['dot', { active: selectedIndices[p.id] === i }]"></span>
                  </div>
                </div>
                <div v-else class="h-100 bg-secondary d-flex align-items-center justify-content-center text-white">
                  <small>Sem foto</small>
                </div>
              </div>

            <div class="card-body">
              <h5 class="card-title">{{ p.title }}</h5>
              <h6 class="card-subtitle mb-2 text-muted">{{ p.city }}, {{ p.state }}</h6>
              <p class="card-text text-truncate">{{ p.description }}</p>
              <p class="h6">{{ formatPrice(p.price) }}</p>
              <p class="small text-muted mb-2">Anunciante: {{ p.agent_name || '—' }}</p>

              <div class="d-flex justify-content-between align-items-center mt-2">
                <div>
                  <router-link :to="{ name: 'properties-show', params: { id: p.id } }" class="btn btn-sm btn-outline-primary me-2">Ver</router-link>
                  <router-link v-if="canEdit(p)" :to="{ name: 'properties-edit', params: { id: p.id } }" class="btn btn-sm btn-outline-secondary me-2">Editar</router-link>
                </div>
                <div class="text-end small text-muted">
                  {{ p.area ? p.area + ' m²' : '—' }} · {{ p.bedrooms }} quartos · {{ p.parking_spaces }} vagas
                </div>
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

const properties = ref([])
const loading = ref(true)
const error = ref(null)
const currentUser = ref(null)

// novo: mapa de índices de foto por property id
const selectedIndices = ref({})

const getCsrf = () => document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

const fetchCurrent = async () => {
  try {
    const res = await fetch('/current_user')
    if (res.ok) currentUser.value = await res.json()
  } catch (e) { /* silent */ }
}

const fetchProperties = async () => {
  loading.value = true
  error.value = null
  try {
    const res = await fetch('/properties.json')
    if (!res.ok) throw new Error(await res.text())
    properties.value = await res.json()
    // inicializa índices para cada imóvel (0)
    properties.value.forEach(p => {
      selectedIndices.value[p.id] = 0
    })
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  await fetchCurrent()
  await fetchProperties()
})

const formatPrice = (v) => {
  if (v == null) return '—'
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(Number(v))
}

const canEdit = (p) => {
  if (!currentUser.value) return false
  if (currentUser.value.role === 'admin' || currentUser.value.role === 2) return true
  return currentUser.value.role === 'agent' && (currentUser.value.id === p.agent_id)
}

const canDelete = canEdit

// computed seguro para exibir o botão "Novo imóvel"
const canCreate = computed(() => {
  if (!currentUser.value) return false
  const role = currentUser.value.role
  return role === 'admin' || role === 2 || role === 'agent'
})

const remove = async (id) => {
  if (!confirm('Confirma exclusão do imóvel?')) return
  try {
    const res = await fetch(`/properties/${id}.json`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': getCsrf()
      }
    })
    if (!res.ok) throw new Error('Falha ao excluir')
    properties.value = properties.value.filter(p => p.id !== id)
  } catch (e) {
    alert(e.message)
  }
}

// navegação de fotos por imóvel
const prevPhoto = (propertyId) => {
  const p = properties.value.find(x => x.id === propertyId)
  if (!p || !p.photos_urls || p.photos_urls.length === 0) return
  const len = p.photos_urls.length
  selectedIndices.value[propertyId] = (selectedIndices.value[propertyId] - 1 + len) % len
}

const nextPhoto = (propertyId) => {
  const p = properties.value.find(x => x.id === propertyId)
  if (!p || !p.photos_urls || p.photos_urls.length === 0) return
  const len = p.photos_urls.length
  selectedIndices.value[propertyId] = (selectedIndices.value[propertyId] + 1) % len
}

const currentPhotoUrl = (propertyId, prop) => {
  if (!prop || !prop.photos_urls || prop.photos_urls.length === 0) return null
  const idx = selectedIndices.value[propertyId] ?? 0
  return prop.photos_urls[idx] || prop.photos_urls[0]
}
</script>

<style scoped>
.card-text { max-height: 4.5em; overflow: hidden; }

/* image area */
.card-img-top { position: relative; }
.object-cover { object-fit: cover; height: 100%; }

/* arrows on card */
.card-arrow {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(26,46,102,0.65);
  color: #fff;
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.25rem;
  cursor: pointer;
  z-index: 5;
}
.card-arrow.left { left: 10px; }
.card-arrow.right { right: 10px; }
.card-arrow:hover { background: rgba(26,46,102,0.85); }

/* small dots under image */
.photo-dots {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  bottom: 8px;
  display: flex;
  gap: 6px;
  z-index: 6;
}
.dot {
  width: 8px;
  height: 8px;
  background: rgba(255,255,255,0.6);
  border-radius: 50%;
  opacity: 0.8;
}
.dot.active { background: #1A2E66; opacity: 1; }

/* responsive adjustments */
@media (max-width: 576px) {
  .card-img-top { height: 160px; }
  .card-arrow { width: 30px; height: 30px; font-size: 1rem; }
}
</style>
