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
</script>

<style scoped>
.card { overflow: hidden; }
</style>
