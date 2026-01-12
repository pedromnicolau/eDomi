<template>
  <div class="card p-2" :style="{ background: '#f8f9fb' }">
    <div class="d-flex align-items-center mb-2">
      <div :style="{ width: '10px', height: '10px', background: column.color, borderRadius: '2px', marginRight: '8px' }"></div>
      <strong>{{ column.name }}</strong>
      <div class="ms-auto">
        <button class="btn btn-sm btn-outline-secondary me-1" @click="openEdit">Editar</button>
        <button class="btn btn-sm btn-danger" @click="remove">Excluir</button>
      </div>
    </div>

    <div class="cards-list" @dragover.prevent @drop="onDrop($event)">
      <div v-for="(card, idx) in column.cards" :key="card.id" class="mb-2" draggable="true" @dragstart="onDragStart(card, column)" >
        <KanbanCard :card="card" @open-edit="openCard(card)" />
      </div>
    </div>

    <div class="mt-2">
      <button class="btn btn-sm btn-outline-primary w-100" @click="openNewCard">+ Novo cartão</button>
    </div>

    <CardModal v-if="showCardModal" :card="editingCard" :column="column" @saved="onCardSaved" @closed="closeModal" />

    <div v-if="editingColumn" class="mt-2">
      <input v-model="editName" class="form-control form-control-sm mb-1" />
      <input type="color" v-model="editColor" class="form-control form-control-sm mb-1" />
      <div class="d-flex gap-2">
        <button class="btn btn-primary btn-sm" @click="saveEdit">Salvar</button>
        <button class="btn btn-link btn-sm" @click="cancelEdit">Cancelar</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import KanbanCard from './KanbanCard.vue'
import CardModal from './CardModal.vue'
import * as api from '@/api/kanban'

const props = defineProps({ column: Object })
const emit = defineEmits(['update-column', 'delete-column', 'create-card', 'move-card'])

const editingColumn = ref(false)
const editName = ref('')
const editColor = ref('#7c8cff')

const showCardModal = ref(false)
const editingCard = ref(null)

function openEdit() {
  editingColumn.value = true
  editName.value = props.column.name
  editColor.value = props.column.color || '#7c8cff'
}
function cancelEdit() { editingColumn.value = false }
async function saveEdit() {
  const updated = await api.updateColumn(props.column.id, { name: editName.value, color: editColor.value })
  emit('update-column', updated)
  editingColumn.value = false
}

async function remove() {
  if (!confirm('Excluir coluna e seus cartões?')) return
  await api.deleteColumn(props.column.id)
  emit('delete-column', props.column.id)
}

function openNewCard() { editingCard.value = null; showCardModal.value = true }
function openCard(card) { editingCard.value = card; showCardModal.value = true }

async function onCardSaved(card) {
  // if card is new, push
  if (!props.column.cards.find(c => c.id === card.id)) {
    props.column.cards.push(card)
    emit('create-card', card, props.column.id)
  } else {
    const idx = props.column.cards.findIndex(c => c.id === card.id)
    props.column.cards[idx] = card
  }
  showCardModal.value = false
}

function closeModal() { showCardModal.value = false }

function onDragStart(card, column) {
  event.dataTransfer.setData('text/plain', JSON.stringify({ cardId: card.id, fromColumnId: column.id }))
}

function onDrop(ev) {
  const raw = ev.dataTransfer.getData('text/plain')
  if (!raw) return
  const data = JSON.parse(raw)
  const toPosition = props.column.cards.length
  emit('move-card', { cardId: data.cardId, fromColumnId: data.fromColumnId, toColumnId: props.column.id, toPosition })
}
</script>

<style scoped>
.cards-list { min-height: 40px }
.kanban-column { width: 300px }
</style>
