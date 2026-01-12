<template>
  <div class="card p-2">
    <div class="d-flex align-items-start">
      <div class="me-2" style="flex:1">
        <div class="fw-semibold">{{ card.title }}</div>
        <div class="text-muted small">{{ card.client_info?.name || '' }}</div>
      </div>
      <div>
        <button class="btn btn-sm btn-outline-secondary" @click="$emit('open-edit')">Abrir</button>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({ card: Object })
</script>

<style scoped>
.card { cursor: grab }
</style>
