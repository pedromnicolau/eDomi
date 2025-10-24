<template>
  <div class="admin-panel">
    <div class="container">
      <div class="admin-toolbar d-flex align-items-center mb-3">
       <h3 class="me-auto">Cadastros — Usuários</h3>
       <div class="d-flex align-items-center">
         <div class="search-wrapper me-2">
           <input v-model="query" class="form-control form-control-sm" placeholder="Filtrar por nome ou email..." />
           <i class="fa fa-search search-icon" aria-hidden="true"></i>
         </div>
         <button class="btn add-btn btn-sm" @click="addNew">Adicionar novo(a)</button>
       </div>
     </div>

      <div class="admin-card">
        <div v-if="loading" class="text-muted">Carregando...</div>
        <div v-else class="table-responsive">
          <table class="table table-sm">
           <thead>
             <tr>
               <th>Nome</th>
               <th>Email</th>
               <th>Função</th>
             </tr>
           </thead>
           <tbody>
             <tr v-for="u in filtered" :key="u.id">
               <td>{{ u.name || '-' }}</td>
               <td>{{ u.email || '-' }}</td>
               <td>{{ u.role || '-' }}</td>
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

const fetchRecords = async () => {
  loading.value = true
  try {
    const res = await fetch('/users.json', { credentials: 'same-origin' })
    if (res.ok) records.value = await res.json()
    else records.value = []
  } catch (e) { records.value = [] }
  loading.value = false
}

onMounted(fetchRecords)

const fields = ['name','email','role']
const filtered = computed(() => {
  const q = String(query.value || '').trim().toLowerCase()
  if (!q) return records.value
  return records.value.filter(r => fields.some(f => String(r[f] || '').toLowerCase().includes(q)))
})

const addNew = () => {
  // roteamento para signup para criar usuário (ajuste conforme backend)
  router.push({ name: 'sign-up' }).catch(()=>{})
}
</script>

<style scoped>
/* same modern styles as other cadastros */
.admin-panel { padding: 1.25rem 0 2.5rem; }
.container { max-width: 1140px; }
.admin-card { background: #fff; border-radius: 14px; box-shadow: 0 10px 30px rgba(15, 35, 77, 0.06); border: 1px solid rgba(15,35,77,0.06); }
.admin-toolbar h3 { margin: 0; font-weight: 600; color: #0f254d; font-size: 1.25rem; }
.search-wrapper { position: relative; min-width: 260px; }
.search-wrapper .search-icon { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: rgba(15,35,77,0.28); font-size: 0.9rem; }
.search-wrapper input { padding: 10px 12px 10px 36px; border-radius: 999px; border: 1px solid rgba(15,35,77,0.06); background: #f6f8fb; }
.add-btn { background: #4ADE80; color: #08203a; border: 0; font-weight: 600; border-radius: 999px; padding: 0.42rem 0.9rem; box-shadow: 0 6px 18px rgba(10,20,30,0.06); }
.table thead th { background: transparent; color: rgba(15,35,77,0.85); font-weight: 700; border-bottom: 1px solid rgba(15,35,77,0.06); padding: 12px; }
.table tbody td { padding: 12px; color: #1f2d47; border-bottom: 1px solid rgba(15,35,77,0.04); }

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

@media (max-width: 768px) {
  .container { padding-left: 16px; padding-right: 16px; }
  .admin-toolbar { flex-direction: column; align-items: stretch; gap: 8px; }
  .search-wrapper { width: 100%; }
  .add-btn { width: 100%; }
}
</style>
