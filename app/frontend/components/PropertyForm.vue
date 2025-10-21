<template>
  <div class="container py-4">
    <h1 class="h5 mb-3">{{ isEdit ? 'Editar Imóvel' : 'Novo Imóvel' }}</h1>

    <div v-if="loading" class="text-center">Carregando...</div>
    <div v-else>
      <div v-if="error" class="alert alert-danger">{{ error }}</div>

      <form @submit.prevent="submit">
        <div class="mb-3">
          <label class="form-label">Título</label>
          <input class="form-control" v-model="form.title" required />
        </div>
        <div class="mb-3">
          <label class="form-label">Preço</label>
          <input type="number" class="form-control" v-model.number="form.price" required />
        </div>
        <div class="mb-3">
          <label class="form-label">Cidade</label>
          <input class="form-control" v-model="form.city" required />
        </div>
        <div class="mb-3">
          <label class="form-label">Estado (2 letras)</label>
          <input class="form-control" v-model="form.state" maxlength="2" required />
        </div>
        <div class="mb-3">
          <label class="form-label">Quartos</label>
          <input type="number" class="form-control" v-model.number="form.bedrooms" min="0" />
        </div>
        <div class="mb-3">
          <label class="form-label">Descrição</label>
          <textarea class="form-control" v-model="form.description"></textarea>
        </div>

        <!-- Address (required) -->
        <div class="mb-3">
          <label class="form-label">Endereço</label>
          <input class="form-control" v-model="form.address" required />
        </div>

        <!-- Neighborhood -->
        <div class="mb-3">
          <label class="form-label">Bairro</label>
          <input class="form-control" v-model="form.neighborhood" />
        </div>

        <!-- ZIP code -->
        <div class="mb-3">
          <label class="form-label">CEP</label>
          <input class="form-control" v-model="form.zip_code" />
        </div>

        <!-- Property type (enum) -->
        <div class="mb-3">
          <label class="form-label">Tipo de imóvel</label>
          <select class="form-select" v-model="form.property_type" required>
            <option disabled value="">Selecione...</option>
            <option value="house">Casa</option>
            <option value="apartment">Apartamento</option>
            <option value="land">Terreno</option>
            <option value="commercial">Comercial</option>
          </select>
        </div>

        <!-- Area -->
        <div class="mb-3">
          <label class="form-label">Área (m²)</label>
          <input type="number" step="0.01" class="form-control" v-model.number="form.area" />
        </div>

        <!-- Bathrooms, Parking -->
        <div class="row g-2 mb-3">
          <div class="col">
            <label class="form-label">Banheiros</label>
            <input type="number" min="0" class="form-control" v-model.number="form.bathrooms" />
          </div>
          <div class="col">
            <label class="form-label">Vagas</label>
            <input type="number" min="0" class="form-control" v-model.number="form.parking_spaces" />
          </div>
        </div>

        <!-- Furnished -->
        <div class="form-check mb-3">
          <input class="form-check-input" type="checkbox" id="furnished" v-model="form.furnished" />
          <label class="form-check-label" for="furnished">Mobiliado</label>
        </div>

        <!-- Fees -->
        <div class="row g-2 mb-3">
          <div class="col">
            <label class="form-label">Condomínio</label>
            <input type="number" step="0.01" min="0" class="form-control" v-model.number="form.condominium_fee" />
          </div>
          <div class="col">
            <label class="form-label">IPTU</label>
            <input type="number" step="0.01" min="0" class="form-control" v-model.number="form.iptu" />
          </div>
        </div>

        <!-- Year built -->
        <div class="mb-3">
          <label class="form-label">Ano de construção</label>
          <input type="number" class="form-control" v-model.number="form.year_built" />
        </div>

        <!-- Status (enum) -->
        <div class="mb-3">
          <label class="form-label">Status</label>
          <select class="form-select" v-model="form.status">
            <option value="available">Disponível</option>
            <option value="under_offer">Em negociação</option>
            <option value="sold">Vendido</option>
          </select>
        </div>

        <button class="btn btn-primary" type="submit">{{ isEdit ? 'Salvar' : 'Criar' }}</button>
        <router-link to="/" class="btn btn-secondary ms-2">Cancelar</router-link>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const id = route.params.id
const isEdit = !!id

const form = ref({
  title: '',
  price: 0,
  property_type: '',     // required
  address: '',           // required
  neighborhood: '',
  zip_code: '',
  city: '',
  state: '',
  area: null,
  bedrooms: 0,
  bathrooms: 0,
  parking_spaces: 0,
  furnished: false,
  condominium_fee: 0.0,
  iptu: 0.0,
  year_built: null,
  status: 'available',
  description: ''
})

const loading = ref(false)
const error = ref(null)

const getCsrf = () => document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

const load = async () => {
  if (!isEdit) return
  loading.value = true
  try {
    const res = await fetch(`/properties/${id}.json`)
    if (!res.ok) throw new Error('Imóvel não encontrado')
    const data = await res.json()
    Object.assign(form.value, {
      title: data.title,
      price: data.price,
      property_type: data.property_type || '',
      address: data.address || '',
      neighborhood: data.neighborhood || '',
      zip_code: data.zip_code || '',
      city: data.city || '',
      state: data.state || '',
      area: data.area,
      bedrooms: data.bedrooms,
      bathrooms: data.bathrooms,
      parking_spaces: data.parking_spaces,
      furnished: data.furnished,
      condominium_fee: data.condominium_fee,
      iptu: data.iptu,
      year_built: data.year_built,
      status: data.status || 'available',
      description: data.description
    })
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

onMounted(load)

const submit = async () => {
  error.value = null

  // simple client-side required checks
  if (!form.value.title || !form.value.price || !form.value.property_type || !form.value.address || !form.value.city || !form.value.state) {
    error.value = 'Preencha os campos obrigatórios: título, preço, tipo, endereço, cidade e estado.'
    return
  }

  try {
    const method = isEdit ? 'PATCH' : 'POST'
    const url = isEdit ? `/properties/${id}.json` : '/properties.json'
    const res = await fetch(url, {
      method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': getCsrf()
      },
      body: JSON.stringify({ property: form.value })
    })
    if (res.status === 422) {
      const body = await res.json()
      throw new Error((body.errors || body.error || ['Erro']).join(', '))
    }
    if (!res.ok) throw new Error('Erro ao salvar')
    router.push({ name: 'home' })
  } catch (e) {
    error.value = e.message
  }
}
</script>
