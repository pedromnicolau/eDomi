<template>
  <div class="users-table">
    <form class="row g-2 align-items-end mb-3" @submit.prevent="fetchUsers">
      <div class="col-auto">
        <label class="form-label">Pesquisar</label>
        <input v-model="q" type="search" class="form-control" placeholder="Nome ou email" />
      </div>
      <div class="col-auto">
        <label class="form-label">Tipo</label>
        <select v-model="role" class="form-select">
          <option value="">Todos</option>
          <option :value="2">Administrador</option>
          <option :value="1">Corretor</option>
          <option :value="0">Usuário</option>
        </select>
      </div>
      <div class="col-auto">
        <button class="btn btn-primary">Filtrar</button>
      </div>
    </form>

    <div v-if="loading" class="text-muted">Carregando usuários...</div>
    <div v-else>
      <div v-if="error" class="alert alert-danger">{{ error }}</div>
      <div v-else>
        <div class="mb-2 small text-muted">Exibindo {{ users.length }} usuários</div>
        <table class="table table-sm">
          <thead>
            <tr>
              <th>ID</th>
              <th>Nome</th>
              <th>Email</th>
              <th>Tipo (role)</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="u in users" :key="u.id">
              <td>{{ u.id }}</td>
              <td>{{ u.name || '—' }}</td>
              <td>{{ u.email }}</td>
              <td>{{ roleLabel(u.role) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const users = ref([])
const q = ref('')
const role = ref('')
const loading = ref(false)
const error = ref(null)

const fetchUsers = async () => {
  loading.value = true
  error.value = null
  try {
    const params = new URLSearchParams()
    if (q.value) params.append('q', q.value)
    if (role.value !== '') params.append('role', role.value)
    const res = await fetch(`/users.json?${params.toString()}`, { credentials: 'same-origin' })
    if (!res.ok) throw new Error('Falha ao buscar usuários')
    users.value = await res.json()
  } catch (e) {
    error.value = e.message || 'Erro'
  } finally {
    loading.value = false
  }
}

const roleLabel = (r) => {
  if (r === 2 || String(r) === '2') return 'Administrador'
  if (r === 1 || String(r) === '1') return 'Corretor'
  return 'Usuário'
}

fetchUsers()
</script>

<style scoped>
.users-table { max-width: 100%; }
</style>
