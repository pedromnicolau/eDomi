<template>
  <div class="container py-5">
    <div class="card shadow-sm">
      <div class="card-body">
        <h1 class="h3 mb-3">Hello World (Vue 3 + Vite + Rails)</h1>

        <p class="mb-1">SPA rodando com Bootstrap 🎉</p>
        <p class="mb-1">Olá, {{ name }} — contador: {{ count }}</p>

        <button class="btn btn-primary me-2" @click="inc()">Incrementar</button>
        <button class="btn btn-secondary" @click="editing = !editing">
          {{ editing ? 'Cancelar' : 'Mudar Nome' }}
        </button>

        <!-- Input para digitar o nome -->
        <div v-if="editing" class="mt-3">
          <input type="text" v-model="tempName" class="form-control mb-2" placeholder="Digite seu nome">
          <button class="btn btn-success" @click="saveName()">Salvar</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  name: {
    type: String,
    default: 'Visitante'
  }
})

// estado do contador
const count = ref(0)
const inc = (step = 1) => count.value += step

// estado de edição do nome
const editing = ref(false)
const tempName = ref(props.name)  // armazena temporariamente o novo nome
const name = ref(props.name)      // nome que aparece no HTML

const saveName = () => {
  name.value = tempName.value
  editing.value = false
}
</script>
