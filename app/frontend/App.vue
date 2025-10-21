<template>
  <Navbar />
  <div class="min-vh-100"><router-view /></div>
  <Footer />
</template>

<script setup>
import Navbar from './components/Navbar.vue'
import Footer from './components/Footer.vue'
</script>

<style>
/* ...optional global styles... */
</style>
