<template>
  <div class="property-form-container py-4">
    <div class="form-card shadow-sm rounded-4 p-4 bg-white mx-auto">
      <h1 class="h5 fw-semibold mb-4">
        {{ isEdit ? 'Editar Imóvel' : 'Novo Imóvel' }}
      </h1>

      <div v-if="loading" class="py-5 text-muted">Carregando...</div>
      <div v-else>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>

        <form @submit.prevent="submit" enctype="multipart/form-data" novalidate>
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label">Título</label>
              <input class="form-control form-control-lg" v-model="form.title" required />
            </div>
            <div class="col-md-6">
              <label class="form-label">Preço (R$)</label>
              <input type="number" class="form-control form-control-lg" v-model.number="form.price" required />
            </div>

            <div class="col-md-6">
              <label class="form-label">Cidade</label>
              <input class="form-control" v-model="form.city" required />
            </div>
            <div class="col-md-6">
              <label class="form-label">Estado (2 letras)</label>
              <input class="form-control text-uppercase" maxlength="2" v-model="form.state" required />
            </div>

            <div class="col-md-4">
              <label class="form-label">Quartos</label>
              <input type="number" class="form-control" v-model.number="form.bedrooms" min="0" />
            </div>
            <div class="col-md-4">
              <label class="form-label">Banheiros</label>
              <input type="number" class="form-control" v-model.number="form.bathrooms" min="0" />
            </div>
            <div class="col-md-4">
              <label class="form-label">Vagas</label>
              <input type="number" class="form-control" v-model.number="form.parking_spaces" min="0" />
            </div>

            <div class="col-md-12">
              <label class="form-label">Descrição</label>
              <textarea class="form-control" rows="3" v-model="form.description"></textarea>
            </div>

            <div class="col-md-12">
              <label class="form-label">Endereço</label>
              <input class="form-control" v-model="form.address" required />
            </div>

            <div class="col-md-6">
              <label class="form-label">Bairro</label>
              <input class="form-control" v-model="form.neighborhood" />
            </div>
            <div class="col-md-6">
              <label class="form-label">CEP</label>
              <input class="form-control" v-model="form.zip_code" />
            </div>

            <div class="col-md-6">
              <label class="form-label">Tipo de imóvel</label>
              <select class="form-select" v-model="form.property_type" required>
                <option disabled value="">Selecione...</option>
                <option value="house">Casa</option>
                <option value="apartment">Apartamento</option>
                <option value="land">Terreno</option>
                <option value="commercial">Comercial</option>
              </select>
            </div>
            <div class="col-md-6">
              <label class="form-label">Área (m²)</label>
              <input type="number" step="0.01" class="form-control" v-model.number="form.area" />
            </div>

            <div class="col-md-6">
              <label class="form-label">Condomínio (R$)</label>
              <input type="number" step="0.01" min="0" class="form-control" v-model.number="form.condominium_fee" />
            </div>
            <div class="col-md-6">
              <label class="form-label">IPTU (R$)</label>
              <input type="number" step="0.01" min="0" class="form-control" v-model.number="form.iptu" />
            </div>

            <div class="col-md-6">
              <label class="form-label">Ano de construção</label>
              <input type="number" class="form-control" v-model.number="form.year_built" />
            </div>

            <div class="col-md-6">
              <label class="form-label">Status</label>
              <select class="form-select" v-model="form.status">
                <option value="available">Disponível</option>
                <option value="under_offer">Em negociação</option>
                <option value="sold">Vendido</option>
              </select>
            </div>

            <div class="col-12">
              <div class="form-check form-switch mt-2">
                <input class="form-check-input" type="checkbox" id="furnished" v-model="form.furnished" />
                <label class="form-check-label" for="furnished">Mobiliado</label>
              </div>
            </div>

            <!-- Upload de imagens -->
            <div class="col-12 mt-3">
              <label class="form-label">Fotos do imóvel</label>
              <input ref="fileInput" type="file" multiple class="form-control" @change="onFilesChange" />

              <!-- previews -->
              <div v-if="previewUrls.length" class="preview-container mt-3 d-flex flex-wrap gap-3">
                <div
                  v-for="(u,i) in previewUrls"
                  :key="'new-'+i"
                  class="preview-box position-relative shadow-sm rounded"
                >
                  <img :src="u" class="preview-img rounded-3" />
                  <button
                    type="button"
                    class="btn btn-sm btn-danger position-absolute"
                    style="right:-8px;top:-8px;border-radius:50%;"
                    @click="removeNewFile(i)"
                  >&times;</button>
                </div>
              </div>

              <!-- fotos já existentes -->
              <div v-if="existingPhotos.length" class="mt-3">
                <div class="small mb-1 fw-semibold text-muted">Fotos já anexadas</div>
                <div class="d-flex flex-wrap gap-3">
                  <div
                    v-for="(p, idx) in existingPhotos"
                    :key="p.blob_id"
                    class="preview-box position-relative shadow-sm rounded"
                  >
                    <img :src="p.url" :alt="p.filename" class="preview-img rounded-3" />
                    <button
                      type="button"
                      class="btn btn-sm btn-danger position-absolute"
                      style="right:-8px;top:-8px;border-radius:50%;"
                      @click="markRemoveExisting(p.blob_id)"
                    >&times;</button>
                  </div>
                </div>
                <div v-if="removedBlobIds.length" class="text-muted small mt-2">
                  Marcou {{ removedBlobIds.length }} foto(s) para remoção
                </div>
              </div>
            </div>
          </div>

          <div class="mt-4">
            <button
              class="btn btn-primary px-5 py-2 fw-semibold shadow-sm"
              type="submit"
              :disabled="submitting"
            >
              <span v-if="submitting" class="d-inline-flex align-items-center">
                <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
                Salvando...
              </span>
              <span v-else>
                {{ isEdit ? 'Salvar Alterações' : 'Criar Imóvel' }}
              </span>
            </button>
            <router-link to="/" class="btn btn-outline-secondary ms-2 px-4 py-2">Cancelar</router-link>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const id = route.params.id
const isEdit = Boolean(id)

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

// novo estado para submissão
const submitting = ref(false)
const success = ref(null)

const files = ref([])
const previewUrls = ref([])

// fotos já atreladas e removidas
const existingPhotos = ref([]) // objetos { blob_id, filename, url }
const removedBlobIds = ref([])

const fileInput = ref(null)

const getCsrf = () => {
  try {
    return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
  } catch {
    return ''
  }
}

const load = async () => {
  if (!isEdit) return
  loading.value = true
  try {
    const res = await fetch(`/properties/${id}.json`, { credentials: 'same-origin' })
    if (!res.ok) throw new Error('Imóvel não encontrado')
    const data = await res.json()
    Object.assign(form.value, {
      title: data.title ?? '',
      price: data.price ?? 0,
      property_type: data.property_type ?? '',
      address: data.address ?? '',
      neighborhood: data.neighborhood ?? '',
      zip_code: data.zip_code ?? '',
      city: data.city ?? '',
      state: data.state ?? '',
      area: data.area ?? null,
      bedrooms: data.bedrooms ?? 0,
      bathrooms: data.bathrooms ?? 0,
      parking_spaces: data.parking_spaces ?? 0,
      furnished: data.furnished ?? false,
      condominium_fee: data.condominium_fee ?? 0.0,
      iptu: data.iptu ?? 0.0,
      year_built: data.year_built ?? null,
      status: data.status ?? 'available',
      description: data.description ?? ''
    })
    existingPhotos.value = data.photos_data || []
  } catch (e) {
    error.value = e.message || String(e)
  } finally {
    loading.value = false
  }
}

onMounted(load)

// revoke object URLs on unmount
onBeforeUnmount(() => {
  previewUrls.value.forEach(u => {
    try { URL.revokeObjectURL(u) } catch {}
  })
})

// arquivos selecionados
const onFilesChange = (e) => {
  const incoming = Array.from(e.target.files || [])
  // revoke previous previews
  previewUrls.value.forEach(u => { try { URL.revokeObjectURL(u) } catch {} })
  files.value = incoming
  previewUrls.value = files.value.map(f => URL.createObjectURL(f))
}

// remove um novo arquivo selecionado antes do envio
const removeNewFile = (index) => {
  if (previewUrls.value[index]) {
    try { URL.revokeObjectURL(previewUrls.value[index]) } catch {}
  }
  files.value.splice(index, 1)
  previewUrls.value.splice(index, 1)
  // clear file input if none left to allow re-upload of same files
  if (fileInput.value && files.value.length === 0) fileInput.value.value = ''
}

// marcar uma foto existente para remoção (toggle)
const markRemoveExisting = (blobId) => {
  const n = Number(blobId)
  if (removedBlobIds.value.includes(n)) {
    removedBlobIds.value = removedBlobIds.value.filter(x => x !== n)
    // opcional: re-add original photo to list (não re-fetch para simplicidade)
  } else {
    removedBlobIds.value.push(n)
    existingPhotos.value = existingPhotos.value.filter(p => Number(p.blob_id) !== n)
  }
}

const submit = async () => {
  error.value = null
  success.value = null

  // validacoes simples
  if (!form.value.title || !form.value.price || !form.value.property_type || !form.value.address || !form.value.city || !form.value.state) {
    error.value = 'Preencha os campos obrigatórios: título, preço, tipo, endereço, cidade e estado.'
    return
  }

  submitting.value = true
  try {
    const method = isEdit ? 'PATCH' : 'POST'
    const url = isEdit ? `/properties/${id}.json` : '/properties.json'

    const hasFiles = files.value.length > 0
    const hasRemovals = removedBlobIds.value.length > 0

    let body, headers = {}
    if (hasFiles || hasRemovals) {
      body = new FormData()
      // append property fields safely converting to strings
      Object.keys(form.value).forEach(k => {
        const v = form.value[k]
        if (v === undefined || v === null) return
        // boolean -> string, numbers -> string
        body.append(`property[${k}]`, (typeof v === 'object') ? JSON.stringify(v) : String(v))
      })
      files.value.forEach(f => body.append('property[uploaded_photos][]', f))
      removedBlobIds.value.forEach(id => body.append('property[remove_photo_blob_ids][]', String(id)))
      headers['X-CSRF-Token'] = getCsrf()
      // do NOT set Content-Type for FormData
    } else {
      body = JSON.stringify({ property: form.value })
      headers['Content-Type'] = 'application/json'
      headers['X-CSRF-Token'] = getCsrf()
    }

    const res = await fetch(url, {
      method,
      headers,
      body,
      credentials: 'same-origin'
    })

    if (res.status === 422) {
      const bodyErr = await res.json().catch(() => null)
      throw new Error((bodyErr && (bodyErr.errors || bodyErr.error)) || 'Erro de validação')
    }
    if (!res.ok) {
      const txt = await res.text().catch(() => '')
      throw new Error(txt || 'Erro ao salvar')
    }

    // sucesso — navegar para raiz da SPA
    router.push({ path: '/' })
  } catch (e) {
    error.value = e.message || String(e)
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.property-form-container {
  background-color: #f9fafc;
  min-height: 100vh;
}

.form-card {
  max-width: 900px;
}

.preview-box {
  width: 110px;
  height: 80px;
  overflow: hidden;
  border: 1px solid #ddd;
  background-color: #f8f9fa;
  position: relative;
}

.preview-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.form-control:focus,
.form-select:focus {
  border-color: #0d6efd;
  box-shadow: 0 0 0 0.15rem rgba(13, 110, 253, 0.25);
}

.btn-primary {
  background-color: #0d6efd;
  border: none;
}

.btn-primary:hover {
  background-color: #0b5ed7;
}

.btn-outline-secondary:hover {
  background-color: #f1f1f1;
}
</style>
