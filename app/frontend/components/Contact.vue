<template>
  <div class="container py-4">
    <div class="row g-4">
      <div class="col-md-6">
        <h2>Contato</h2>
        <p class="mb-1"><strong>eDomi Imobiliária</strong></p>
        <p class="mb-1">Telefone: (11) 4000-0000</p>
        <p class="mb-1">E-mail: contato@edomi.example</p>
        <p class="mb-1">Endereço: Rua Exemplo, 123 — São Paulo, SP</p>
      </div>

      <div class="col-md-6">
        <h3>Envie uma mensagem</h3>
        <div v-if="success" class="alert alert-success">{{ success }}</div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>

        <form @submit.prevent="send">
          <div class="mb-2">
            <label class="form-label small">Nome</label>
            <input v-model="name" class="form-control" required />
          </div>
          <div class="mb-2">
            <label class="form-label small">E-mail</label>
            <input v-model="email" type="email" class="form-control" required />
          </div>
          <div class="mb-2">
            <label class="form-label small">Mensagem</label>
            <textarea v-model="message" class="form-control" rows="5" required></textarea>
          </div>
          <div class="d-flex align-items-center">
            <button class="btn btn-primary me-2" :disabled="sending">{{ sending ? 'Enviando...' : 'Enviar' }}</button>
            <button type="button" class="btn btn-outline-secondary" @click="clear">Limpar</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const name = ref('')
const email = ref('')
const message = ref('')
const sending = ref(false)
const success = ref(null)
const error = ref(null)

const send = async () => {
  success.value = error.value = null
  if (!name.value || !email.value || !message.value) {
    error.value = 'Preencha todos os campos.'
    return
  }
  sending.value = true
  try {
    const res = await fetch('/contacts.json', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ contact: { name: name.value, email: email.value, message: message.value } }),
      credentials: 'same-origin'
    })
    if (res.ok) {
      success.value = 'Mensagem enviada. Entraremos em contato em breve.'
      clear()
    } else {
      const j = await res.json().catch(() => null)
      error.value = (j && j.error) || 'Erro ao enviar mensagem.'
    }
  } catch (e) {
    error.value = 'Erro de rede.'
  } finally {
    sending.value = false
  }
}

const clear = () => {
  name.value = ''
  email.value = ''
  message.value = ''
}
</script>

<style scoped>
/* ajustes simples */
</style>
