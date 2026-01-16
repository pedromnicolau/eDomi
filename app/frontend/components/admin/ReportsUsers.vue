<template>
  <div class="admin-panel">
    <div class="container">
      <div class="admin-toolbar d-flex align-items-center mb-3">
       <h3 class="me-auto">Pessoas</h3>
       <div class="d-flex align-items-center gap-2">
          <input v-model="filterName" class="form-control form-control-sm" placeholder="Filtrar por nome" />
          <input v-model="filterPhone" class="form-control form-control-sm" placeholder="Filtrar por telefone" />
          <button class="add-btn" @click="openCreateModal">
            <i class="fa-solid fa-plus me-1"></i>Nova Pessoa
          </button>
       </div>
     </div>

      <div class="admin-card">
        <div v-if="loading" class="text-muted p-3">Carregando...</div>
        <div v-else class="table-responsive">
          <table class="table table-sm">
           <thead>
             <tr>
               <th>Nome</th>
               <th>Telefone</th>
               <th>Email</th>
               <th>Papel</th>
               <th style="width: 120px;">Ações</th>
             </tr>
           </thead>
           <tbody>
             <tr v-for="u in paginatedData" :key="u.id">
               <td>{{ u.name || '-' }}</td>
               <td>{{ u.phone || '-' }}</td>
               <td>{{ u.email || '-' }}</td>
               <td>{{ roleLabel(u.role) }}</td>
               <td>
                 <button class="btn btn-sm btn-outline-primary me-1" @click="openEditModal(u)" title="Editar">
                   <i class="fa-solid fa-pen"></i>
                 </button>
                 <button class="btn btn-sm btn-outline-danger" @click="confirmDelete(u)" title="Excluir">
                   <i class="fa-solid fa-trash"></i>
                 </button>
               </td>
             </tr>
           </tbody>
          </table>
        </div>
        
        <!-- Pagination -->
        <div v-if="!loading && filtered.length > 0" class="pagination-wrapper">
          <div class="pagination-info">
            Mostrando {{ paginationStart }} - {{ paginationEnd }} de {{ filtered.length }} pessoas
          </div>
          
          <div class="pagination-controls">
            <button 
              class="pagination-btn" 
              :disabled="currentPage === 1"
              @click="currentPage = 1"
              title="Primeira página"
            >
              <i class="fa-solid fa-angles-left"></i>
            </button>
            
            <button 
              class="pagination-btn" 
              :disabled="currentPage === 1"
              @click="currentPage--"
              title="Página anterior"
            >
              <i class="fa-solid fa-angle-left"></i>
            </button>
            
            <div class="pagination-pages">
              <button
                v-for="page in visiblePages"
                :key="page"
                class="pagination-page"
                :class="{ active: page === currentPage }"
                @click="currentPage = page"
              >
                {{ page }}
              </button>
            </div>
            
            <button 
              class="pagination-btn" 
              :disabled="currentPage === totalPages"
              @click="currentPage++"
              title="Próxima página"
            >
              <i class="fa-solid fa-angle-right"></i>
            </button>
            
            <button 
              class="pagination-btn" 
              :disabled="currentPage === totalPages"
              @click="currentPage = totalPages"
              title="Última página"
            >
              <i class="fa-solid fa-angles-right"></i>
            </button>
          </div>
          
          <div class="items-per-page">
            <label>Por página:</label>
            <select v-model="itemsPerPage" class="items-select">
              <option :value="10">10</option>
              <option :value="25">25</option>
              <option :value="50">50</option>
              <option :value="100">100</option>
            </select>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de edição/criação -->
    <div v-if="showModal" class="modal-overlay" @click.self="closeModal">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ editingPerson?.id ? 'Editar Pessoa' : 'Nova Pessoa' }}</h5>
            <button type="button" class="btn-close" @click="closeModal"></button>
          </div>
          <div class="modal-body">
            <div class="mb-3">
              <label class="form-label">Nome *</label>
              <input v-model="formData.name" type="text" class="form-control" placeholder="Nome completo" />
            </div>
            <PhoneInput
              v-model="formData.phone"
              label="Telefone"
              :error="phoneError"
              @update:error="phoneError = $event"
            />
            <div class="mb-3">
              <label class="form-label">Email</label>
              <input v-model="formData.email" type="email" class="form-control" placeholder="email@exemplo.com" />
            </div>
            <div class="mb-3">
              <label class="form-label">Papel</label>
              <select v-model="formData.role" class="form-control">
                <option v-for="option in roleOptions" :key="option.value" :value="option.value">
                  {{ option.label }}
                </option>
              </select>
            </div>
            <div class="mb-3">
              <label class="form-label">CPF</label>
              <input v-model="formData.cpf" type="text" class="form-control" placeholder="000.000.000-00" />
            </div>
            <div class="mb-3">
              <label class="form-label">Notas</label>
              <textarea v-model="formData.notes" class="form-control" rows="3" placeholder="Observações adicionais"></textarea>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeModal">Cancelar</button>
            <button type="button" class="btn btn-primary" @click="savePerson" :disabled="saving">
              <span v-if="saving">Salvando...</span>
              <span v-else>{{ editingPerson?.id ? 'Salvar' : 'Criar' }}</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de confirmação de exclusão -->
    <div v-if="showDeleteConfirm" class="modal-overlay" @click.self="showDeleteConfirm = false">
      <div class="modal-dialog modal-sm">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Confirmar Exclusão</h5>
            <button type="button" class="btn-close" @click="showDeleteConfirm = false"></button>
          </div>
          <div class="modal-body">
            <p>Tem certeza que deseja excluir <strong>{{ personToDelete?.name }}</strong>?</p>
            <p class="text-muted small mb-0">Esta ação não pode ser desfeita.</p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="showDeleteConfirm = false">Cancelar</button>
            <button type="button" class="btn btn-danger" @click="deletePerson" :disabled="deleting">
              <span v-if="deleting">Excluindo...</span>
              <span v-else>Excluir</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import PhoneInput from '../shared/PhoneInput.vue'
const router = useRouter()
const records = ref([])
const loading = ref(false)
const query = ref('')
const filterName = ref('')
const filterPhone = ref('')
const showModal = ref(false)
const editingPerson = ref(null)
const saving = ref(false)
const showDeleteConfirm = ref(false)
const personToDelete = ref(null)
const deleting = ref(false)
const currentPage = ref(1)
const itemsPerPage = ref(10)
const phoneError = ref('')
const roleOptions = [
  { value: 'cliente', label: 'Cliente' },
  { value: 'investidor', label: 'Investidor' },
  { value: 'proprietario', label: 'Proprietário' },
  { value: 'corretor', label: 'Corretor' },
  { value: 'parceiro', label: 'Parceiro' },
  { value: 'inquilino', label: 'Inquilino' },
  { value: 'lead', label: 'Lead' }
]
const roleLabels = roleOptions.reduce((acc, option) => {
  acc[option.value] = option.label
  return acc
}, {})
const roleLabel = role => roleLabels[role] || '-'

const handleEscape = event => {
  if (event.key === 'Escape') {
    if (showModal.value) closeModal()
    if (showDeleteConfirm.value) showDeleteConfirm.value = false
  }
}

const formData = ref({
  name: '',
  phone: '',
  email: '',
  cpf: '',
  notes: '',
  role: 'cliente'
})

const getCsrf = () => document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

const fetchRecords = async () => {
  loading.value = true
  try {
    const res = await fetch('/people.json', { credentials: 'same-origin' })
    if (res.ok) records.value = await res.json()
    else records.value = []
  } catch (e) { records.value = [] }
  loading.value = false
}

onMounted(() => {
  fetchRecords()
  window.addEventListener('keydown', handleEscape)
})

onBeforeUnmount(() => {
  window.removeEventListener('keydown', handleEscape)
})

const filtered = computed(() => {
  const list = records.value || []
  const n = String(filterName.value || '').trim().toLowerCase()
  const p = String(filterPhone.value || '').trim().toLowerCase()

  return list.filter(r => {
    // strings: se o filtro estiver vazio, aceita; caso contrário verifica includes
    if (n && !String(r.name || '').toLowerCase().includes(n)) return false
    if (p && !String(r.phone || '').toLowerCase().includes(p)) return false

    return true
  })
})

// Pagination computed properties
const totalPages = computed(() => {
  return Math.ceil(filtered.value.length / itemsPerPage.value) || 1
})

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return filtered.value.slice(start, end)
})

const paginationStart = computed(() => {
  if (filtered.value.length === 0) return 0
  return (currentPage.value - 1) * itemsPerPage.value + 1
})

const paginationEnd = computed(() => {
  const end = currentPage.value * itemsPerPage.value
  return Math.min(end, filtered.value.length)
})

const visiblePages = computed(() => {
  const pages = []
  const total = totalPages.value
  const current = currentPage.value
  
  if (total <= 7) {
    // Show all pages if 7 or less
    for (let i = 1; i <= total; i++) {
      pages.push(i)
    }
  } else {
    // Always show first page
    pages.push(1)
    
    if (current > 3) {
      pages.push('...')
    }
    
    // Show pages around current
    const start = Math.max(2, current - 1)
    const end = Math.min(total - 1, current + 1)
    
    for (let i = start; i <= end; i++) {
      pages.push(i)
    }
    
    if (current < total - 2) {
      pages.push('...')
    }
    
    // Always show last page
    pages.push(total)
  }
  
  return pages
})

// Reset to page 1 when filters change
const resetPagination = () => {
  currentPage.value = 1
}

// Watch filters to reset pagination
import { watch } from 'vue'
watch([filterName, filterPhone], resetPagination)

function openCreateModal() {
  editingPerson.value = null
  formData.value = {
    name: '',
    phone: '',
    email: '',
    cpf: '',
    notes: '',
    role: 'cliente'
  }
  phoneError.value = ''
  showModal.value = true
}

function openEditModal(person) {
  editingPerson.value = person
  formData.value = {
    name: person.name || '',
    phone: person.phone || '',
    email: person.email || '',
    cpf: person.cpf || '',
    notes: person.notes || '',
    role: person.role || 'cliente'
  }
  phoneError.value = ''
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  editingPerson.value = null
}

async function savePerson() {
  if (!formData.value.name?.trim()) {
    alert('Nome é obrigatório')
    return
  }
  
  // Valida telefone se preenchido (erro já está no phoneError)
  if (phoneError.value) {
    alert('Por favor, corrija o telefone: ' + phoneError.value)
    return
  }

  saving.value = true
  try {
    const url = editingPerson.value?.id 
      ? `/people/${editingPerson.value.id}.json`
      : '/people.json'
    
    const method = editingPerson.value?.id ? 'PATCH' : 'POST'
    
    const res = await fetch(url, {
      method,
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': getCsrf()
      },
      body: JSON.stringify({ person: formData.value })
    })

    if (res.ok) {
      await fetchRecords()
      closeModal()
    } else {
      const errorData = await res.json()
      let errorMessage = 'Erro ao salvar'
      
      if (errorData.errors && Array.isArray(errorData.errors) && errorData.errors.length > 0) {
        // Backend validation errors (Rails format)
        errorMessage = errorData.errors.join('\n')
      } else if (errorData.error) {
        // Single error message
        errorMessage = errorData.error
      } else if (errorData.message) {
        // Alternative error format
        errorMessage = errorData.message
      } else {
        // Fallback with status code
        errorMessage = `Erro ao salvar (${res.status})`
      }
      
      alert(errorMessage)
    }
  } catch (e) {
    alert('Erro ao salvar: ' + e.message)
  } finally {
    saving.value = false
  }
}

function confirmDelete(person) {
  personToDelete.value = person
  showDeleteConfirm.value = true
}

async function deletePerson() {
  if (!personToDelete.value?.id) return
  
  deleting.value = true
  try {
    const res = await fetch(`/people/${personToDelete.value.id}.json`, {
      method: 'DELETE',
      credentials: 'same-origin',
      headers: {
        'X-CSRF-Token': getCsrf()
      }
    })

    if (res.ok) {
      await fetchRecords()
      showDeleteConfirm.value = false
      personToDelete.value = null
    } else {
      const errorData = await res.json()
      let errorMessage = 'Erro ao excluir'
      
      if (errorData.errors && Array.isArray(errorData.errors) && errorData.errors.length > 0) {
        errorMessage = errorData.errors.join('\n')
      } else if (errorData.error) {
        errorMessage = errorData.error
      } else if (errorData.message) {
        errorMessage = errorData.message
      } else {
        errorMessage = `Erro ao excluir (${res.status})`
      }
      
      alert(errorMessage)
    }
  } catch (e) {
    alert('Erro ao excluir: ' + e.message)
  } finally {
    deleting.value = false
  }
}

</script>

<style scoped>
/* same modern styles as other cadastros */
.admin-panel { padding: 1.25rem 0 2.5rem; }
.container {
  max-width: 80%;
}
.admin-card { background: #fff; border-radius: 14px; box-shadow: 0 10px 30px rgba(15, 35, 77, 0.06); border: 1px solid rgba(15,35,77,0.06); }
.admin-toolbar h3 { margin: 0; font-weight: 600; color: #0f254d; font-size: 1.25rem; }
.search-wrapper { position: relative; min-width: 260px; }
.search-wrapper .search-icon { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: rgba(15,35,77,0.28); font-size: 0.9rem; }
.search-wrapper input { padding: 10px 12px 10px 36px; border-radius: 999px; border: 1px solid rgba(15,35,77,0.06); background: #f6f8fb; }
.add-btn {
  background: linear-gradient(135deg, #22c55e, #16a34a);
  color: #ffffff;
  border: none;
  font-weight: 400;
  border-radius: 8px;
  padding: 0.32rem 0.78rem;
  box-shadow: 0 8px 20px rgba(22, 163, 74, 0.25);
  transition: transform 0.12s ease, box-shadow 0.18s ease, filter 0.18s ease;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 0.9rem;
  line-height: 1.05;
}
.table thead th { background: transparent; color: rgba(15,35,77,0.85); font-weight: 700; border-bottom: 1px solid rgba(15,35,77,0.06); padding: 12px; }
.table tbody td { padding: 12px; color: #1f2d47; border-bottom: 1px solid rgba(15,35,77,0.04); }

.add-btn:hover,
.add-btn:focus {
  transform: translateY(-1px);
  box-shadow: 0 10px 24px rgba(22, 163, 74, 0.3);
  filter: brightness(1.04);
}

/* zebra striping: linhas alternadas */
.table tbody tr:nth-child(odd) {
  background-color: #ffffff;
}
.table tbody tr:nth-child(even) {
  background-color: #f6f8fb;
}

/* hover distincto sobre qualquer linha */
.table tbody tr:hover {
  background-color: rgba(26,46,102,0.06); /* leve tom azul para destacar */
}

.table tbody tr:hover { background: rgba(10, 30, 60, 0.02); }

/* stronger specificity: apply backgrounds to td (overrides Bootstrap) */
.admin-card .table tbody tr:nth-child(odd) td {
  background-color: #ffffff;
}
.admin-card .table tbody tr:nth-child(even) td {
  background-color: #f6f8fb;
}

/* hover should clearly highlight the whole row */
.admin-card .table tbody tr:hover td {
  background-color: rgba(26,46,102,0.06) !important;
}

/* Modal styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1050;
}

.modal-dialog {
  width: 90%;
  max-width: 600px;
  margin: 0 auto;
}

.modal-content {
  background: white;
  border-radius: 12px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  overflow: hidden;
}

.modal-header {
  padding: 1.5rem;
  border-bottom: 1px solid #e9ecef;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.modal-title {
  margin: 0;
  font-weight: 600;
  font-size: 1.25rem;
  color: #0f254d;
}

.btn-close {
  background: transparent;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  opacity: 0.5;
  transition: opacity 0.2s;
  padding: 0;
  width: 24px;
  height: 24px;
}

.btn-close:hover {
  opacity: 1;
}

.btn-close::before {
  content: '×';
}

.modal-body {
  padding: 1.5rem;
  max-height: 70vh;
  overflow-y: auto;
}

.modal-footer {
  padding: 1rem 1.5rem;
  border-top: 1px solid #e9ecef;
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}

.form-label {
  font-weight: 600;
  color: #495057;
  margin-bottom: 0.5rem;
  font-size: 0.9rem;
}

.form-control {
  border-radius: 8px;
  border: 1px solid #dee2e6;
  padding: 0.5rem 0.75rem;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.form-control:focus {
  border-color: #4ADE80;
  box-shadow: 0 0 0 0.2rem rgba(74, 222, 128, 0.25);
  outline: 0;
}

.form-control.is-invalid {
  border-color: #dc3545;
}

.form-control.is-invalid:focus {
  border-color: #dc3545;
  box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25);
}

.invalid-feedback {
  color: #dc3545;
  font-size: 0.875rem;
  margin-top: 0.25rem;
}

.btn {
  border-radius: 8px;
  padding: 0.5rem 1rem;
  font-weight: 600;
  transition: all 0.2s;
}

.btn-primary {
  background: #0d6efd;
  border: none;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #0b5ed7;
  transform: translateY(-1px);
}

.btn-secondary {
  background: #6c757d;
  border: none;
  color: white;
}

.btn-secondary:hover {
  background: #5a6268;
}

.btn-danger {
  background: #dc3545;
  border: none;
  color: white;
}

.btn-danger:hover:not(:disabled) {
  background: #c82333;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.btn-outline-primary {
  border: 1px solid #0d6efd;
  color: #0d6efd;
  background: transparent;
}

.btn-outline-primary:hover {
  background: #0d6efd;
  color: white;
}

.btn-outline-danger {
  border: 1px solid #dc3545;
  color: #dc3545;
  background: transparent;
}

.btn-outline-danger:hover {
  background: #dc3545;
  color: white;
}

.modal-sm {
  max-width: 400px;
}

/* Pagination Styles */
.pagination-wrapper {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 1.25rem;
  border-top: 1px solid rgba(15, 35, 77, 0.06);
  gap: 1rem;
  flex-wrap: wrap;
}

.pagination-info {
  font-size: 0.875rem;
  color: rgba(15, 35, 77, 0.6);
  font-weight: 500;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.pagination-btn {
  width: 32px;
  height: 32px;
  border: 1px solid rgba(15, 35, 77, 0.1);
  background: white;
  color: rgba(15, 35, 77, 0.7);
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 0.875rem;
}

.pagination-btn:hover:not(:disabled) {
  background: rgba(15, 35, 77, 0.04);
  border-color: rgba(15, 35, 77, 0.15);
  color: rgba(15, 35, 77, 0.9);
}

.pagination-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.pagination-pages {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  margin: 0 0.25rem;
}

.pagination-page {
  min-width: 32px;
  height: 32px;
  padding: 0 0.5rem;
  border: 1px solid rgba(15, 35, 77, 0.1);
  background: white;
  color: rgba(15, 35, 77, 0.7);
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 0.875rem;
  font-weight: 500;
}

.pagination-page:hover:not(.active) {
  background: rgba(15, 35, 77, 0.04);
  border-color: rgba(15, 35, 77, 0.15);
  color: rgba(15, 35, 77, 0.9);
}

.pagination-page.active {
  background: linear-gradient(135deg, #22c55e, #16a34a);
  color: white;
  border-color: transparent;
  box-shadow: 0 2px 8px rgba(22, 163, 74, 0.25);
}

.items-per-page {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: rgba(15, 35, 77, 0.7);
  font-weight: 500;
}

.items-select {
  padding: 0.375rem 0.75rem;
  border: 1px solid rgba(15, 35, 77, 0.1);
  border-radius: 6px;
  background: white;
  color: rgba(15, 35, 77, 0.8);
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s ease;
  font-weight: 500;
}

.items-select:hover {
  border-color: rgba(15, 35, 77, 0.2);
}

.items-select:focus {
  outline: none;
  border-color: #22c55e;
  box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.1);
}

@media (max-width: 768px) {
  .container { padding-left: 16px; padding-right: 16px; }
  .admin-toolbar { flex-direction: column; align-items: stretch; gap: 8px; }
  .search-wrapper { width: 100%; }
  .add-btn { width: 100%; }
  
  .modal-dialog {
    width: 95%;
  }
  
  .modal-body {
    max-height: 60vh;
  }
  
  .pagination-wrapper {
    flex-direction: column;
    align-items: stretch;
    gap: 0.75rem;
  }
  
  .pagination-info {
    text-align: center;
  }
  
  .pagination-controls {
    justify-content: center;
  }
  
  .items-per-page {
    justify-content: center;
  }
  
  .pagination-pages {
    margin: 0 0.125rem;
  }
  
  .pagination-page,
  .pagination-btn {
    width: 28px;
    height: 28px;
    min-width: 28px;
    font-size: 0.8rem;
  }
}
</style>
