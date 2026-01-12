<template>
  <div class="card p-3">
    <div class="d-flex mb-2">
      <h5 class="me-auto">{{ card && card.id ? 'Editar cartão' : 'Novo cartão' }}</h5>
      <button class="btn btn-sm btn-outline-secondary" @click="$emit('closed')">Fechar</button>
    </div>

    <div>
      <input v-model="title" class="form-control mb-2" placeholder="Título" />
      <textarea v-model="description" class="form-control mb-2" rows="3" placeholder="Descrição"></textarea>

      <input v-model="clientName" class="form-control mb-2" placeholder="Nome do cliente" />

      <label class="form-label small">Anexos</label>
      <input type="file" multiple @change="onFiles" class="form-control form-control-sm mb-2" />

      <div class="d-flex gap-2">
        <button class="btn btn-primary" @click="save">Salvar</button>
        <button class="btn btn-link" @click="$emit('closed')">Cancelar</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import * as api from '@/api/kanban'

const props = defineProps({ card: Object, column: Object })
const emit = defineEmits(['saved','closed'])

const title = ref(props.card?.title || '')
const description = ref(props.card?.description || '')
const clientName = ref(props.card?.client_info?.name || '')
const files = ref([])

function onFiles(e) { files.value = Array.from(e.target.files) }

async function save() {
  const payload = {
    title: title.value,
    description: description.value,
    kanban_column_id: props.column.id,
    client_info: { name: clientName.value }
  }

  try {
    let saved
    if (props.card && props.card.id) {
      saved = await api.updateCard(props.card.id, payload, files.value)
    } else {
      saved = await api.createCard(payload, files.value)
    }
    emit('saved', saved)
  } catch (e) {
    alert('Erro ao salvar: ' + (e?.error || JSON.stringify(e)))
  }
}
</script>

<style scoped>
.card { width: 320px }
</style>
