<template>
  <div class="sales-list-container p-4">
    <h1 class="h5 mb-3">Vendas</h1>

    <div v-if="loading" class="text-muted">Carregando...</div>
    <div v-else>
      <table class="table table-striped">
        <thead>
          <tr>
            <th>Imóvel</th>
            <th>Agente</th>
            <th>Valor</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="sale in sales" :key="sale.id">
            <td>{{ sale.property_title || '-' }}</td>
            <td>{{ sale.agent_name || '-' }}</td>
            <td>{{ sale.value ? formatCurrency(sale.value) : '-' }}</td>
          </tr>
          <tr v-if="sales.length === 0">
            <td colspan="3" class="text-center text-muted">Nenhuma venda encontrada</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const sales = ref([])
const loading = ref(false)

const formatCurrency = (value) => {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value)
}

const loadSales = async () => {
  loading.value = true
  try {
    const res = await fetch('/sales.json', { credentials: 'same-origin' })
    if (!res.ok) throw new Error('Erro ao carregar vendas')
    const data = await res.json()
    sales.value = data
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

onMounted(loadSales)
</script>

<style scoped>
.sales-list-container {
  max-width: 900px;
  margin: 0 auto;
}
</style>
