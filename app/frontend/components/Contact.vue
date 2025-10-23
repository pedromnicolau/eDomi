<template>
  <div class="contact-page py-5">
    <div class="container">
      <div class="row g-4">
        <!-- Contato -->
        <div class="col-md-6 contact-info">
          <h2>Contato</h2>
          <p class="mb-1"><strong>eDomi Imobiliária</strong></p>
          <p class="mb-1">📞 (13) 97825-2727</p>
          <p class="mb-1">✉️ contato@edomi.com.br</p>
          <p class="mb-1">📍 Avenida Epitácio Pessoa, nº 62, cj. 12, Boqueirão, Santos</p>
        </div>

        <!-- Formulário -->
        <div class="col-md-6 contact-form">
          <h3>Envie uma mensagem</h3>

          <div v-if="success" class="alert alert-success">{{ success }}</div>
          <div v-if="error" class="alert alert-danger">{{ error }}</div>

          <form @submit.prevent="send">
            <div class="mb-3">
              <label class="form-label small">Nome</label>
              <input v-model="name" class="form-control" placeholder="Seu nome" required />
            </div>

            <div class="mb-3">
              <label class="form-label small">E-mail</label>
              <input v-model="email" type="email" class="form-control" placeholder="seu@email.com" required />
            </div>

            <div class="mb-3">
              <label class="form-label small">Mensagem</label>
              <textarea v-model="message" class="form-control" rows="5" placeholder="Escreva sua mensagem..." required></textarea>
            </div>

            <div class="d-flex align-items-center gap-2">
              <button class="btn btn-primary" :disabled="sending">{{ sending ? 'Enviando...' : 'Enviar' }}</button>
              <button type="button" class="btn btn-outline-secondary" @click="clear">Limpar</button>
            </div>
          </form>
        </div>
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
.contact-page {
  background: #f9fafc;
  min-height: 100vh;
  font-family: "Inter", sans-serif;
}

h2, h3 {
  color: #0d6efd;
  margin-bottom: 1rem;
}

.contact-info p {
  font-size: 0.95rem;
  color: #495057;
}

.contact-form .form-control {
  border-radius: 6px;
  padding: 0.75rem;
  font-size: 0.95rem;
  transition: 0.2s;
}

.contact-form .form-control:focus {
  border-color: #0d6efd;
  box-shadow: 0 0 0 0.15rem rgba(13,110,253,0.25);
}

.contact-form textarea.form-control {
  resize: none;
}

.btn-primary {
  background-color: #0d6efd;
  border: none;
  transition: 0.2s;
  border-radius: 6px;
}

.btn-primary:hover {
  background-color: #0b5ed7;
}

.btn-outline-secondary {
  border-radius: 6px;
  transition: 0.2s;
}

.btn-outline-secondary:hover {
  background-color: #e2e6ea;
}

.alert {
  border-radius: 6px;
  font-size: 0.9rem;
  padding: 0.5rem 1rem;
}

.row.g-4 > .col-md-6 {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

.d-flex.align-items-center.gap-2 {
  margin-top: 0.5rem;
}
</style>