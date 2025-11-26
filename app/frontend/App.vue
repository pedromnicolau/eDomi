<template>
  <Navbar />
  <div class="min-vh-100">
    <transition name="fade">
      <div
        v-if="accountDeletedMessage"
        class="alert alert-success account-deleted-alert overlay-alert d-flex justify-content-between align-items-start shadow-sm"
        data-autoclose="false"
        role="alert"
      >
        <div>{{ accountDeletedMessage }}</div>
        <button type="button" class="btn-close" aria-label="Fechar" @click="dismissAccountDeleted"></button>
      </div>
    </transition>
    <router-view />
  </div>
  <Footer />
</template>

<script setup>
import Navbar from './components/Navbar.vue'
import Footer from './components/Footer.vue'
import { ref, onMounted } from 'vue'

const accountDeletedMessage = ref('')

onMounted(() => {
  try {
    if (localStorage.getItem('accountDeleted') === '1') {
      accountDeletedMessage.value = 'Sua conta foi excluída com sucesso.'
      localStorage.removeItem('accountDeleted')
      setTimeout(() => {
        dismissAccountDeleted()
      }, 5000)
    }
  } catch {}
})

const dismissAccountDeleted = () => {
  accountDeletedMessage.value = ''
}
</script>

<style>
.green {
  color: #4ADE80;
}
/* alerta de conta excluída dimensionado e centralizado */
.account-deleted-alert {
  max-width: 520px;
  padding: 0.85rem 1rem;
  border-radius: 0.5rem;
}

/* overlay positioning so it doesn't push layout */
.overlay-alert {
  position: fixed;
  top: 1rem;
  left: 50%;
  transform: translateX(-50%);
  z-index: 5000;
  width: calc(100% - 2rem);
  max-width: 520px;
  margin: 0;
}

/* transição suave */
.fade-enter-active, .fade-leave-active { transition: opacity .35s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
