<template>
  <nav class="navbar navbar-expand-lg navbar-light bg-light">
    <div class="container">
      <router-link class="navbar-brand" to="/">eDomi</router-link>
      <div class="collapse navbar-collapse">
        <ul class="navbar-nav me-auto">
          <li class="nav-item"><router-link class="nav-link" to="/">Imóveis</router-link></li>
          <li class="nav-item"><router-link class="nav-link" to="/about">About</router-link></li>
          <li v-if="canCreate" class="nav-item"><router-link class="nav-link" to="/properties/new">Novo Imóvel</router-link></li>
        </ul>

        <div class="d-flex align-items-center">
          <template v-if="user">
            <span class="me-3 small">Olá, {{ user.name || user.email }}</span>
            <button class="btn btn-outline-secondary" @click="logout">Sair</button>
          </template>
          <template v-else>
            <router-link class="btn btn-outline-primary me-2" to="/users/sign_in">Entrar</router-link>
            <router-link class="btn btn-outline-secondary" to="/users/sign_up">Registrar</router-link>
          </template>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const user = ref(null)
const canCreate = ref(false)

const getCsrf = () => document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

const fetchCurrent = async () => {
  try {
    const res = await fetch('/current_user')
    if (res.ok) {
      user.value = await res.json()
      canCreate.value = user.value && (user.value.role === 'agent' || user.value.role === 'admin')
    } else {
      user.value = null
      canCreate.value = false
    }
  } catch (e) {
    user.value = null
    canCreate.value = false
  }
}

const logout = async () => {
  try {
    const res = await fetch('/users/sign_out', {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': getCsrf()
      },
      credentials: 'same-origin'
    })
    if (res.ok || res.status === 302 || res.status === 204) {
      window.location.reload()
    } else {
      const txt = await res.text()
      alert('Falha no logout: ' + txt)
    }
  } catch (e) {
    alert('Erro ao efetuar logout.')
  }
}

onMounted(fetchCurrent)
</script>

<style scoped>
.navbar { margin-bottom: 1rem; }
</style>
<style scoped>
.navbar { margin-bottom: 1rem; }
</style>
