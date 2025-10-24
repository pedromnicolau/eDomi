<template>
  <div class="admin-layout">
    <AdminNavbar />
    <main class="container-fluid py-4">
      <router-view />
    </main>
  </div>
</template>

<script setup>
import AdminNavbar from './AdminNavbar.vue'
</script>

<style scoped>
.admin-layout {
  min-height: 100vh;
  background: #f8f9fa;
}
</style>
