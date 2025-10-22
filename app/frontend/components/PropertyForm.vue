<template>
  <div class="container py-4">
    <h1 class="h5 mb-3">{{ isEdit ? 'Editar Imóvel' : 'Novo Imóvel' }}</h1>

    <div v-if="loading" class="text-center">Carregando...</div>
    <div v-else>
      <div v-if="error" class="alert alert-danger">{{ error }}</div>

      <form @submit.prevent="submit" enctype="multipart/form-data">
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

        <!-- Image uploads -->
        <div class="mb-3">
          <label class="form-label">Fotos do imóvel (opcional)</label>
          <input type="file" multiple class="form-control" @change="onFilesChange" />
          <!-- previews para novos arquivos -->
          <div v-if="previewUrls.length" class="mt-2 d-flex gap-2 flex-wrap">
            <div v-for="(u,i) in previewUrls" :key="'new-'+i" class="position-relative">
              <img :src="u" style="width:96px;height:72px;object-fit:cover;border-radius:6px;border:1px solid #ddd" />
              <button type="button" class="btn btn-sm btn-danger position-absolute" style="right:-6px;bottom:-6px;padding:0.15rem 0.35rem;" @click="removeNewFile(i)">&times;</button>
            </div>
          </div>

          <!-- fotos já atreladas ao imóvel (quando em edição) -->
          <div v-if="existingPhotos.length" class="mt-3">
            <div class="small mb-1">Fotos já anexadas</div>
            <div class="d-flex gap-2 flex-wrap">
              <div v-for="(p, idx) in existingPhotos" :key="p.blob_id" class="position-relative">
                <img :src="p.url" :alt="p.filename" style="width:96px;height:72px;object-fit:cover;border-radius:6px;border:1px solid #ddd" />
                <button type="button" class="btn btn-sm btn-danger position-absolute" style="right:-6px;bottom:-6px;padding:0.15rem 0.35rem;" @click="markRemoveExisting(p.blob_id)">
                  &times;
                </button>
              </div>
            </div>
            <div v-if="removedBlobIds.length" class="text-muted small mt-1">Marcou {{ removedBlobIds.length }} foto(s) para remoção</div>
          </div>
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

const files = ref([])
const previewUrls = ref([])

// novos estados: fotos existentes e removidas
const existingPhotos = ref([]) // objetos { blob_id, filename, url }
const removedBlobIds = ref([])

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
    // popular fotos existentes (photos_data exposto pelo backend)
    existingPhotos.value = data.photos_data || []
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

onMounted(load)

const onFilesChange = (e) => {
  files.value = Array.from(e.target.files || [])
  // generate previews
  previewUrls.value = files.value.map(f => URL.createObjectURL(f))
}

// remove um novo arquivo selecionado antes do envio
const removeNewFile = (index) => {
  // revoke objectURL
  URL.revokeObjectURL(previewUrls.value[index])
  files.value.splice(index, 1)
  previewUrls.value.splice(index, 1)
}

// marcar uma foto existente para remoção (toggle)
const markRemoveExisting = (blobId) => {
  const id = Number(blobId)
  if (removedBlobIds.value.includes(id)) {
    removedBlobIds.value = removedBlobIds.value.filter(x => x !== id)
    // opcional: re-add visual placeholder? Recarregar existingPhotos from property would be heavier; keep simple
  } else {
    removedBlobIds.value.push(id)
    // remover visualmente da lista
    existingPhotos.value = existingPhotos.value.filter(p => Number(p.blob_id) !== id)
  }
}

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

    // use FormData when files present or when removing existing photos
    let body, headers
    const hasFiles = files.value.length > 0
    const hasRemovals = removedBlobIds.value.length > 0

    if (hasFiles || hasRemovals) {
      body = new FormData()
      // append property fields as nested params: property[title], etc.
      Object.keys(form.value).forEach(k => {
        const v = form.value[k]
        if (v !== undefined && v !== null) body.append(`property[${k}]`, v)
      })
      // append files
      files.value.forEach(f => body.append('property[uploaded_photos][]', f))
      // append removals
      removedBlobIds.value.forEach(id => body.append('property[remove_photo_blob_ids][]', id))
      headers = { 'X-CSRF-Token': getCsrf() }
    } else {
      body = JSON.stringify({ property: form.value })
      headers = {
        'Content-Type': 'application/json',
        'X-CSRF-Token': getCsrf()
      }
    }

    const res = await fetch(url, {
      method,
      headers,
      body,
      credentials: 'same-origin'
    })

    if (res.status === 422) {
      const bodyErr = await res.json().catch(() => null)
      throw new Error((bodyErr && (bodyErr.errors || bodyErr.error)) || 'Erro')
    }
    if (!res.ok) throw new Error('Erro ao salvar')
    router.push({ name: 'home' })
  } catch (e) {
    error.value = e.message
  }
}
</script>
