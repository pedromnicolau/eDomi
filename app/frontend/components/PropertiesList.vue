<template>
  <div class="container py-4">
    <!-- novo botão 'Novo imóvel' posicionado antes do título -->
    <div class="d-flex justify-content-between align-items-center mb-3">
      <div>
        <router-link v-if="canCreate" to="/properties/new" class="btn btn-primary me-2">Novo imóvel</router-link>
      </div>
    </div>

    <h1 class="h4 mb-3">Imóveis disponíveis</h1>

    <div v-if="loading" class="text-center">Carregando...</div>
    <div v-else-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-else>
      <div v-if="properties.length === 0" class="text-muted">Nenhum imóvel encontrado.</div>
      <div class="row g-3">
        <div class="col-md-6" v-for="p in properties" :key="p.id">
          <div class="card h-100">
            <div class="row g-0">
              <div class="col-4">
                <div v-if="p.photos_urls && p.photos_urls.length" class="h-100" style="background:#f6f6f6;display:flex;align-items:center;justify-content:center">
                  <img :src="p.photos_urls[0]" alt="" style="width:100%;height:100%;object-fit:cover" />
                </div>
                <div v-else class="h-100 bg-secondary d-flex align-items-center justify-content-center text-white">
                  <small>Sem foto</small>
                </div>
              </div>
              <div class="col-8">
                <div class="card-body">
                  <h5 class="card-title">{{ p.title }}</h5>
                  <h6 class="card-subtitle mb-2 text-muted">{{ p.city }}, {{ p.state }}</h6>
                  <p class="card-text">{{ p.description }}</p>
                  <p class="h6">{{ formatPrice(p.price) }}</p>
                  <p class="small text-muted mb-2">Anunciante: {{ p.agent_name || '—' }}</p>
                  <router-link :to="{ name: 'properties-show', params: { id: p.id } }" class="btn btn-sm btn-outline-primary me-2">Ver</router-link>
                  <router-link v-if="canEdit(p)" :to="{ name: 'properties-edit', params: { id: p.id } }" class="btn btn-sm btn-outline-secondary me-2">Editar</router-link>
                  <button v-if="canDelete(p)" class="btn btn-sm btn-danger" @click="remove(p.id)">Excluir</button>
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

// substituir a definição problemática por um computed seguro
const canCreate = computed(() => {
  if (!currentUser.value) return false
  const role = currentUser.value.role
  return role === 'admin' || role === 2 || role === 'agent'
})
</script>

<style scoped>
.card-text { max-height: 4.5em; overflow: hidden; }
</style>
