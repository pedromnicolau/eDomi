<template>
  <div class="container py-3">
    <h3>Gerenciamento de Usuários</h3>
    <UsersTable />
  </div>
</template>

<script setup>
import UsersTable from '@/components/admin/UsersTable.vue'
</script>

<style scoped>
.container { max-width: 1100px; }
</style>
