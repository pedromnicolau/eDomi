<template>
  <div class="container py-5">
    <div v-if="loading" class="text-center py-5">Carregando imóveis...</div>
    <div v-else-if="error" class="alert alert-danger">Erro ao carregar imóveis: {{ error }}</div>
    <div v-else>
      <h1 class="h3 mb-4">Imóveis disponíveis</h1>
      <div v-if="properties.length === 0" class="text-muted">Nenhum imóvel encontrado.</div>
      <div class="row g-3">
        <div class="col-md-6" v-for="prop in properties" :key="prop.id">
          <div class="card h-100">
            <div class="card-body">
              <h5 class="card-title">{{ prop.title }}</h5>
              <h6 class="card-subtitle mb-2 text-muted">{{ prop.city }}, {{ prop.state }}</h6>
              <p class="card-text text-truncate" style="max-height: 3.6em;">{{ prop.description }}</p>
              <ul class="list-inline small mb-2">
                <li class="list-inline-item">Quartos: {{ prop.bedrooms ?? 0 }}</li>
                <li class="list-inline-item">Banheiros: {{ prop.bathrooms ?? 0 }}</li>
                <li class="list-inline-item">Vagas: {{ prop.parking_spaces ?? 0 }}</li>
              </ul>
              <p class="h5 mb-1">{{ formatPrice(prop.price) }}</p>
              <p class="mb-0 small text-muted">Anunciante: {{ prop.agent_name ?? '—' }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const properties = ref([])
const loading = ref(true)
const error = ref(null)

const fetchProperties = async () => {
  loading.value = true
  error.value = null
  try {
    const res = await fetch('/properties.json')
    if (!res.ok) throw new Error(`${res.status} ${res.statusText}`)
    properties.value = await res.json()
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

onMounted(fetchProperties)

const formatPrice = (value) => {
  if (value == null) return '—'
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(Number(value))
}
</script>

<style scoped>
.card-text { max-height: 4.5em; overflow: hidden; }
</style>
