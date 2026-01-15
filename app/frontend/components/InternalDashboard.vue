<template>
  <div class="container py-4">
    <KanbanBoard />
  </div>
</template>

<script setup>
import KanbanBoard from './kanban/KanbanBoard.vue'
</script>

<style scoped>
.container { max-width: 80%; }
</style>
