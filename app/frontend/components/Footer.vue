<template>
  <footer class="site-footer">
    <div class="container small text-center">© eDomi — Sistema de anúncios imobiliários</div>
  </footer>
</template>

<script setup>
</script>

<style scoped>
.site-footer {
  background: #1A2E66;
  color: #ffffff;
  width: 100%;
  padding: 1rem;
  border-radius: 0;
}

.site-footer .container,
.site-footer .small {
  color: #ffffff;
}

@media (max-width: 576px) {
  .site-footer { padding: 0.6rem 0.75rem; }
}
</style>
