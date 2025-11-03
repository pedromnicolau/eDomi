<template>
  <div class="admin-panel">
    <div class="container">
      <div class="admin-toolbar d-flex align-items-center mb-3">
       <h3 class="me-auto">Cadastros — Comissões</h3>
       <div class="d-flex align-items-center">
          <div class="col-md-6">
           <input v-model="filterAgente" class="form-control form-control-sm" placeholder="Filtrar por corretor" />
          </div>
          <div class="col-md-6">
           <input v-model="filterSale" class="form-control form-control-sm" placeholder="Filtrar por venda" />
          </div>
       </div>
      </div>

      <div class="admin-card">
        <div v-if="loading" class="text-muted">Carregando...</div>
        <div v-else class="table-responsive">
          <table class="table table-sm">
           <thead>
             <tr>
               <th>Corretor</th>
               <th>Percentual</th>
               <th>Valor</th>
             </tr>
           </thead>
           <tbody>
             <tr v-for="c in filtered" :key="c.id">
               <td>{{ c.agent_name || '-' }}</td>
               <td>{{ c.percentage ? c.percentage + '%' : '-' }}</td>
               <td>{{ c.value ? formatCurrency(c.value) : '-' }}</td>
               <td><router-link :to="{ name: 'sales-list', params: { id: c.id } }" class="btn btn-sm btn-outline-primary me-2">Vendas</router-link></td>
             </tr>
           </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
const router = useRouter()
const records = ref([])
const loading = ref(false)
const query = ref('')
const filterAgente = ref('')
const filterSale = ref('')

const fetchRecords = async () => {
  loading.value = true
  try {
    const res = await fetch('/commissions.json', { credentials: 'same-origin' })
    if (res.ok) records.value = await res.json()
    else records.value = []
  } catch (e) { records.value = [] }
  loading.value = false
}

onMounted(fetchRecords)

const filtered = computed(() => {
  const list = records.value || []
  const a = String(filterAgente.value || '').trim().toLowerCase()
  const s = String(filterSale.value || '').trim().toLowerCase()

  return list.filter(r => {
    // strings: se o filtro estiver vazio, aceita; caso contrário verifica includes
    if (a && !String(r.agent_name || '').toLowerCase().includes(a)) return false
    if (s && !String(r.sale_name || '').toLowerCase().includes(s)) return false

    return true
  })
})

const addNew = () => {
  router.push({ path: '/commissions/new' }).catch(()=>{ alert('Rota de criação de comissão não implementada') })
}

const formatCurrency = (v) => {
  try { return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(Number(v)) } catch(e) { return v }
}
</script>

<style scoped>
.admin-panel { padding: 1.25rem 0 2.5rem; }
.container {
  max-width: 1140px;
  margin: 0 auto;
  padding-left: 24px;
  padding-right: 24px;
}
.admin-card { background: #fff; border-radius: 14px; padding: 18px; box-shadow: 0 10px 30px rgba(15,35,77,0.06); border: 1px solid rgba(15,35,77,0.06); }
.admin-toolbar h3 { margin: 0; font-weight: 600; color: #0f254d; font-size: 1.25rem; }
.search-wrapper { position: relative; min-width: 260px; }
.search-wrapper .search-icon { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: rgba(15,35,77,0.28); font-size: 0.9rem; }
.search-wrapper input { padding: 10px 12px 10px 36px; border-radius: 999px; border: 1px solid rgba(15,35,77,0.06); background: #f6f8fb; }
.add-btn { background: #4ADE80; color: #08203a; border: 0; font-weight: 600; border-radius: 999px; padding: 0.42rem 0.9rem; box-shadow: 0 6px 18px rgba(10,20,30,0.06); }
.table thead th { background: transparent; color: rgba(15,35,77,0.85); font-weight: 700; border-bottom: 1px solid rgba(15,35,77,0.06); padding: 12px; }
.table tbody td { padding: 12px; color: #1f2d47; border-bottom: 1px solid rgba(15,35,77,0.04); }
.admin-card .table tbody tr:nth-child(odd) td {
  background-color: #ffffff;
}
.admin-card .table tbody tr:nth-child(even) td {
  background-color: #f6f8fb;
}

.admin-card .table tbody tr:hover td {
  background-color: rgba(26,46,102,0.06) !important;
}
@media (max-width: 768px) {
  .container { padding-left: 16px; padding-right: 16px; }
  .admin-toolbar { flex-direction: column; align-items: stretch; gap: 8px; }
  .search-wrapper { width: 100%; }
  .add-btn { width: 100%; }
}
</style>
