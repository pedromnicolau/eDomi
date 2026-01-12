<template>
  <div class="container py-4">
    <h1 class="h4">Sistema Interno</h1>
    <p class="text-muted">Área interna para administradores e corretores.</p>
    <KanbanBoard />
  </div>
</template>

<script setup>
import KanbanBoard from './kanban/KanbanBoard.vue'
</script>

<style scoped>
.container { max-width: 100%; }
</style>
