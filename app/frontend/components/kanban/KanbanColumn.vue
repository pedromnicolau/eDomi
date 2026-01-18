<template>
  <div class="card p-2 kanban-column-wrapper" :style="{ background: '#f8f9fb' }">
    <div class="d-flex align-items-center mb-2 gap-2">
      <div v-if="!editingColumnName && !editingColumnColor" class="d-flex align-items-center w-100 gap-2">
        <div class="column-color-editable" @click="startEditColor" title="Clique para alterar a cor">
          <div :style="{ width: '10px', height: '10px', background: column.color, borderRadius: '2px' }"></div>
        </div>
        <div class="column-name-editable flex-grow-1" @click="startEditName" title="Clique para renomear">
          <strong>{{ column.name }}</strong>
        </div>
        <div class="ms-auto dropdown-container">
          <button class="btn btn-sm btn-outline-secondary" @click.stop="toggleDropdown">⋯</button>
          <div v-if="showDropdown" class="dropdown-menu-custom" @click.stop>
            <button class="dropdown-item text-danger" @click="remove">Excluir</button>
          </div>
        </div>
      </div>
      <div v-else class="d-flex align-items-center w-100 gap-2">
        <input v-if="editingColumnColor" ref="colorInputRef" type="color" v-model="editColor" class="form-control form-control-sm color-input" @change="handleColorBlur" @blur="handleColorBlur" />
        <input v-if="editingColumnName" ref="nameInputRef" v-model="editName" class="form-control form-control-sm" @blur="handleNameBlur" @keyup.enter.prevent="handleNameBlur" />
      </div>
    </div>

    <div class="cards-list" @dragover.prevent @drop="onDrop($event)">
      <div v-for="(card, idx) in column.cards" :key="card.id" class="mb-2" draggable="true" @dragstart="onDragStart(card, column)" >
        <KanbanCard :card="card" @open-edit="openCard(card)" @open-attachment="onOpenAttachment" />
      </div>
    </div>

    <div class="mt-2">
      <button class="btn btn-sm btn-outline-primary w-100" @click="openNewCard">+ Novo cartão</button>
    </div>

    <CardModal
      v-if="showCardModal"
      :card="editingCard"
      :column="column"
      :columns="columns"
      @saved="onCardSaved"
      @deleted="onCardDeleted"
      @move-card="onMoveFromModal"
      @duplicate="onDuplicateFromModal"
      @closed="closeModal"
      @open-attachment="onOpenAttachment"
      @update-card="syncCardFromModal"
    />

    <ConfirmDialog
      :show="confirmDialog.show"
      :title="confirmDialog.title"
      :message="confirmDialog.message"
      @confirm="confirmDialog.onConfirm"
      @cancel="confirmDialog.show = false"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import KanbanCard from './KanbanCard.vue'
import CardModal from './CardModal.vue'
import ConfirmDialog from '@/components/common/ConfirmDialog.vue'
import * as api from '@/api/kanban'

const props = defineProps({ column: Object, columns: { type: Array, default: () => [] } })
const emit = defineEmits(['update-column', 'delete-column', 'create-card', 'move-card', 'open-attachment'])

const editingColumnName = ref(false)
const editingColumnColor = ref(false)
const editName = ref('')
const editColor = ref('#7c8cff')
const nameInputRef = ref(null)
const colorInputRef = ref(null)
const showDropdown = ref(false)

const showCardModal = ref(false)
const editingCard = ref(null)

const confirmDialog = ref({
  show: false,
  title: '',
  message: '',
  onConfirm: null
})

function toggleDropdown() {
  showDropdown.value = !showDropdown.value
}

function startEditName() {
  if (showDropdown.value) return
  editingColumnName.value = true
  editName.value = props.column.name
  nextTick(() => {
    if (nameInputRef.value) {
      nameInputRef.value.focus()
      nameInputRef.value.select()
    }
  })
}

function startEditColor() {
  if (showDropdown.value) return
  editingColumnColor.value = true
  editColor.value = props.column.color || '#7c8cff'
  nextTick(() => {
    if (colorInputRef.value) {
      colorInputRef.value.click()
    }
  })
}

async function handleNameBlur() {
  if (!editingColumnName.value) return
  const name = editName.value.trim()
  editingColumnName.value = false
  
  if (!name || name === props.column.name) return
  
  const updated = await api.updateColumn(props.column.id, { name })
  emit('update-column', updated)
}

async function handleColorBlur() {
  if (!editingColumnColor.value) return
  const color = editColor.value
  editingColumnColor.value = false
  
  if (!color || color === props.column.color) return
  
  const updated = await api.updateColumn(props.column.id, { color })
  emit('update-column', updated)
}

async function remove() {
  showDropdown.value = false
  confirmDialog.value = {
    show: true,
    title: 'Excluir coluna',
    message: 'Tem certeza que deseja excluir esta coluna e todos os seus cartões? Esta ação não pode ser desfeita.',
    onConfirm: async () => {
      confirmDialog.value.show = false
      await api.deleteColumn(props.column.id)
      emit('delete-column', props.column.id)
    }
  }
}

function openNewCard() { editingCard.value = null; showCardModal.value = true }
function openCard(card) { editingCard.value = card; showCardModal.value = true }

function handleClickOutside(event) {
  if (showDropdown.value) {
    showDropdown.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})

async function onCardSaved(card) {
  // if card is new, push
  if (!props.column.cards.find(c => c.id === card.id)) {
    props.column.cards.push(card)
    emit('create-card', card, props.column.id)
  } else {
    const idx = props.column.cards.findIndex(c => c.id === card.id)
    props.column.cards[idx] = card
  }
  editingCard.value = card
}

function closeModal() { showCardModal.value = false }

function onDragStart(card, column) {
  event.dataTransfer.effectAllowed = 'move'
  event.dataTransfer.setData('text/plain', JSON.stringify({ cardId: card.id, fromColumnId: column.id }))
  
  // Adiciona classe ao body para mudar cursor globalmente
  document.body.classList.add('is-dragging-card')
  
  // Remove a classe quando o drag terminar
  event.target.addEventListener('dragend', () => {
    document.body.classList.remove('is-dragging-card')
  }, { once: true })
}

function onDrop(ev) {
  const raw = ev.dataTransfer.getData('text/plain')
  if (!raw) return
  const data = JSON.parse(raw)
  const toPosition = props.column.cards.length
  emit('move-card', { cardId: data.cardId, fromColumnId: data.fromColumnId, toColumnId: props.column.id, toPosition })
}

function onOpenAttachment(payload) {
  emit('open-attachment', payload)
}

function onCardDeleted(cardId) {
  if (!cardId) return
  const idx = props.column.cards.findIndex(c => c.id === cardId)
  if (idx !== -1) props.column.cards.splice(idx, 1)
  showCardModal.value = false
}

function onMoveFromModal({ card, toColumnId }) {
  if (!card?.id || !toColumnId) return
  const fromColumnId = props.column.id
  const target = props.columns?.find?.(c => c.id === toColumnId)
  const toPosition = target && target.cards ? target.cards.length : 0
  emit('move-card', { cardId: card.id, fromColumnId, toColumnId, toPosition })
  showCardModal.value = false
}

function onDuplicateFromModal(card) {
  if (!card?.id) return
  const exists = props.column.cards.find(c => c.id === card.id)
  if (!exists) props.column.cards.push(card)
  emit('create-card', card, props.column.id)
  showCardModal.value = false
}

function syncCardFromModal(card) {
  if (!card?.id) return
  const idx = props.column.cards.findIndex(c => c.id === card.id)
  if (idx !== -1) {
    props.column.cards[idx] = card
  }
}
</script>

<style>
/* Global style - not scoped */
body.is-dragging-card,
body.is-dragging-card * {
  cursor: grabbing !important;
}
</style>

<style scoped>
.kanban-column-wrapper {
  width: 300px;
  flex-shrink: 0;
  position: relative;
}

.color-input {
  width: 48px;
  padding: 2px;
}

.cards-list {
  min-height: 40px;
}

.kanban-column {
  width: 300px;
}

.dropdown-container {
  position: relative;
}

.dropdown-menu-custom {
  position: absolute;
  top: 100%;
  left: 0;
  background: white;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 1050;
  min-width: 120px;
  overflow: hidden;
  margin-top: 4px;
}

.dropdown-item {
  display: block;
  width: 100%;
  padding: 8px 12px;
  border: none;
  background: none;
  text-align: left;
  cursor: pointer;
  font-size: 14px;
  transition: background 0.2s;
}

.dropdown-item:hover {
  background: #f8f9fa;
}

.dropdown-item:first-child {
  border-radius: 4px 4px 0 0;
}

.dropdown-item:last-child {
  border-radius: 0 0 4px 4px;
}

.column-color-editable {
  cursor: pointer;
  padding: 2px;
  border-radius: 4px;
  transition: background-color 0.15s ease;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.column-color-editable:hover {
  background-color: rgba(0, 0, 0, 0.05);
}

.column-name-editable {
  cursor: pointer;
  padding: 2px 6px;
  border-radius: 4px;
  transition: background-color 0.15s ease;
  user-select: none;
}

.column-name-editable:hover {
  background-color: rgba(0, 0, 0, 0.05);
}
</style>
