<template>
  <div class="container py-5">
    <div class="card shadow-sm">
      <div class="card-body">
        <h1 class="h3 mb-3">Hello World (Vue 3 + Vite + Rails)</h1>

        <p class="mb-1">SPA rodando com Bootstrap 🎉</p>
        <p class="mb-1">Olá, {{ name }} — contador: {{ count }}</p>

        <button class="btn btn-primary" @click="inc()">Incrementar</button>
      </div>
    </div>
  </div>
</template>

<script setup>
  import { ref } from 'vue'

  // props (sem tipagem explícita)
  const props = defineProps({
    name: {
      type: String,
      default: 'Visitante'
    }
  })

  // reatividade normal
  const count = ref(0)

  // função JS pura
  // function inc(step = 1) {
  //   count.value += step
  //   return count.value
  // }

  const inc = (step = 1) => {
    count.value += step
    return count.value
  }

  // valor default pra exibir no template
  const name = props.name
</script>


<!-- <script setup lang="ts">
import { ref } from 'vue'

// props tipadas
const props = defineProps<{
  name?: string
}>()

// ref tipada
const count = ref<number>(0)

// função com tipos (argumento + retorno)
function inc(step: number = 1): number {
  count.value += step
  return count.value
}

// valor default pra exibir no template
const name = props.name ?? 'Visitante'
</script> -->
