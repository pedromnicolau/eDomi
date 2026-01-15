<template>
  <div class="kanban-board p-3">
    <div class="d-flex mb-3 align-items-center">
      <button class="btn btn-sm btn-primary" @click="openNewColumn">+ Nova Coluna</button>
      <div class="ms-auto">
        <button class="btn btn-outline-secondary btn-sm" @click="refresh">Atualizar</button>
      </div>
    </div>

    <div class="kanban-columns d-flex gap-3 overflow-auto" ref="board">
      <div v-for="col in columns" :key="col.id" class="kanban-column-card">
        <KanbanColumn :column="col" :columns="columns" @update-column="onUpdateColumn" @delete-column="onDeleteColumn" @create-card="onCreateCard" @move-card="onMoveCard" @open-attachment="onOpenAttachment" />
      </div>

      <div class="kanban-add-column">
        <div v-if="addingColumn" class="card p-2">
          <input v-model="newColumnName" class="form-control form-control-sm mb-2" placeholder="Nome da coluna" />
          <input v-model="newColumnColor" type="color" class="form-control form-control-sm mb-2" />
          <div class="d-flex gap-2">
            <button class="btn btn-sm btn-primary" @click="createColumn">Criar</button>
            <button class="btn btn-sm btn-link" @click="cancelNewColumn">Cancelar</button>
          </div>
        </div>
        <div v-else>
          <button class="btn btn-light btn-sm" @click="openNewColumn">+ Adicionar coluna</button>
        </div>
      </div>
    </div>
    <div v-if="lightboxOpen" class="lightbox-overlay" @click="closeLightbox">
      <div class="lightbox-body" @click.stop>
        <div class="lightbox-header mb-3">
          <div class="d-flex justify-content-between align-items-center mb-2">
            <div class="text-truncate me-3 fw-semibold">{{ currentAttachment?.filename }}</div>
            <button class="btn-close" @click="closeLightbox" aria-label="Fechar"></button>
          </div>
          <div class="lightbox-actions d-flex justify-content-between">
            <div class="d-flex gap-2">
              <a :href="currentAttachment?.url" :download="currentAttachment?.filename" class="btn btn-sm btn-outline-primary">
                <i class="fa-solid fa-download"></i> Baixar
              </a>
              <button v-if="isImage(currentAttachment?.filename)" class="btn btn-sm btn-outline-primary" @click="printAttachment">
                <i class="fa-solid fa-print"></i> Imprimir
              </button>
              <button v-if="isImage(currentAttachment?.filename)" class="btn btn-sm btn-outline-primary" @click="openInNewTab">
                <i class="fa-solid fa-arrow-up-right-from-square"></i> Abrir em nova aba
              </button>
            </div>
            <div v-if="isImage(currentAttachment?.filename)" class="d-flex gap-2 align-items-center">
              <button class="btn btn-sm btn-outline-secondary" @click="zoomOut" :disabled="zoomLevel <= 0.5">
                <i class="fa-solid fa-magnifying-glass-minus"></i>
              </button>
              <span class="text-muted small">{{ Math.round(zoomLevel * 100) }}%</span>
              <button class="btn btn-sm btn-outline-secondary" @click="zoomIn" :disabled="zoomLevel >= 3">
                <i class="fa-solid fa-magnifying-glass-plus"></i>
              </button>
              <button class="btn btn-sm btn-outline-secondary" @click="resetZoom" title="Resetar zoom">
                <i class="fa-solid fa-rotate-right"></i>
              </button>
            </div>
          </div>
        </div>
        
        <div class="lightbox-content" ref="lightboxContentRef">
          <img v-if="isImage(currentAttachment?.filename)" :src="currentAttachment?.url" :alt="currentAttachment?.filename" :style="{ transform: `scale(${zoomLevel})`, cursor: zoomLevel > 1 ? 'move' : 'default' }" @mousedown="startDrag" @load="onImageLoad" />
          <iframe v-else class="file-frame" :src="currentAttachment?.url" title="Arquivo"></iframe>
        </div>
        
        <div class="lightbox-footer">
          <div class="d-flex justify-content-between align-items-center">
            <button class="btn btn-outline-secondary" @click.stop="prevAttachment" :disabled="lightboxItems.length <= 1">
              <i class="bi bi-chevron-left"></i> Anterior
            </button>
            <span class="text-muted small">{{ lightboxIndex + 1 }} / {{ lightboxItems.length }}</span>
            <button class="btn btn-outline-secondary" @click.stop="nextAttachment" :disabled="lightboxItems.length <= 1">
              Próximo <i class="bi bi-chevron-right"></i>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import KanbanColumn from './KanbanColumn.vue'
import * as api from '@/api/kanban'

const currentBoard = ref(null)
const columns = ref([])
const addingColumn = ref(false)
const newColumnName = ref('')
const newColumnColor = ref('#7c8cff')
const lightboxOpen = ref(false)
const lightboxItems = ref([])
const lightboxIndex = ref(0)
const zoomLevel = ref(1)
const baseZoom = ref(1)
const lightboxContentRef = ref(null)
const isDragging = ref(false)
const dragStart = ref({ x: 0, y: 0, scrollLeft: 0, scrollTop: 0 })

async function loadBoard() {
  // For simplicity we fetch the first board or create a default one
  const boards = await api.fetchBoards()
  let board = boards[0]
  if (!board) {
    board = await api.createBoard({ name: 'Pipeline de Vendas' })
  } else {
    board = await api.fetchBoard(board.id)
  }
  currentBoard.value = board
  columns.value = board.columns || []
}

function refresh() { loadBoard() }

function openNewColumn() { addingColumn.value = true }
function cancelNewColumn() { addingColumn.value = false; newColumnName.value = '' }

async function createColumn() {
  if (!newColumnName.value.trim() || !currentBoard.value) return
  const payload = { name: newColumnName.value.trim(), color: newColumnColor.value, kanban_board_id: currentBoard.value.id }
  const created = await api.createColumn(payload)
  columns.value.push(created)
  newColumnName.value = ''
  addingColumn.value = false
}

function onUpdateColumn(updated) {
  const idx = columns.value.findIndex(c => c.id === updated.id)
  if (idx !== -1) columns.value[idx] = updated
}

function onDeleteColumn(id) {
  columns.value = columns.value.filter(c => c.id !== id)
}

function onCreateCard(card, columnId) {
}

function onOpenAttachment(payload) {
  if (!payload?.attachments || payload.attachments.length === 0) return
  baseZoom.value = 1
  zoomLevel.value = 1
  lightboxItems.value = payload.attachments
  lightboxIndex.value = payload.index || 0
  lightboxOpen.value = true
}

const currentAttachment = computed(() => lightboxItems.value[lightboxIndex.value] || null)

function closeLightbox() {
  lightboxOpen.value = false
  lightboxItems.value = []
  lightboxIndex.value = 0
  zoomLevel.value = 1
  baseZoom.value = 1
}

function nextAttachment() {
  if (lightboxItems.value.length === 0) return
  lightboxIndex.value = (lightboxIndex.value + 1) % lightboxItems.value.length
  baseZoom.value = 1
  resetZoom()
}

function prevAttachment() {
  if (lightboxItems.value.length === 0) return
  lightboxIndex.value = (lightboxIndex.value - 1 + lightboxItems.value.length) % lightboxItems.value.length
  baseZoom.value = 1
  resetZoom()
}

function isImage(filename) {
  if (!filename) return false
  const imageExts = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg']
  const ext = filename.split('.').pop().toLowerCase()
  return imageExts.includes(ext)
}

function printAttachment() {
  if (!currentAttachment.value?.url) return
  const printWindow = window.open(currentAttachment.value.url, '_blank')
  if (printWindow) {
    printWindow.onload = () => {
      printWindow.print()
    }
  }
}

function openInNewTab() {
  if (!currentAttachment.value?.url) return
  window.open(currentAttachment.value.url, '_blank')
}

function zoomIn() {
  if (zoomLevel.value < 3) zoomLevel.value = Math.min(3, zoomLevel.value + 0.25)
}

function zoomOut() {
  if (zoomLevel.value > 0.5) zoomLevel.value = Math.max(0.5, zoomLevel.value - 0.25)
}

function resetZoom() {
  zoomLevel.value = baseZoom.value
  if (lightboxContentRef.value) {
    lightboxContentRef.value.scrollLeft = 0
    lightboxContentRef.value.scrollTop = 0
  }
}

function startDrag(e) {
  if (zoomLevel.value <= 1) return
  isDragging.value = true
  const container = lightboxContentRef.value
  if (!container) return
  dragStart.value = {
    x: e.clientX,
    y: e.clientY,
    scrollLeft: container.scrollLeft,
    scrollTop: container.scrollTop
  }
  
  const onMouseMove = (e) => {
    if (!isDragging.value) return
    e.preventDefault()
    const dx = e.clientX - dragStart.value.x
    const dy = e.clientY - dragStart.value.y
    container.scrollLeft = dragStart.value.scrollLeft - dx
    container.scrollTop = dragStart.value.scrollTop - dy
  }
  
  const onMouseUp = () => {
    isDragging.value = false
    document.removeEventListener('mousemove', onMouseMove)
    document.removeEventListener('mouseup', onMouseUp)
  }
  
  document.addEventListener('mousemove', onMouseMove)
  document.addEventListener('mouseup', onMouseUp)
}

function computeFitZoom(imgEl) {
  const container = lightboxContentRef.value
  if (!container || !imgEl?.naturalWidth || !imgEl?.naturalHeight) return 1
  const cw = container.clientWidth || 1
  const ch = container.clientHeight || 1
  const iw = imgEl.naturalWidth
  const ih = imgEl.naturalHeight
  const ratio = Math.min(cw / iw, ch / ih, 1)
  return ratio || 1
}

function onImageLoad(event) {
  const fitZoom = computeFitZoom(event.target)
  baseZoom.value = fitZoom
  zoomLevel.value = fitZoom
  resetZoom()
}

async function onMoveCard({ cardId, fromColumnId, toColumnId, toPosition }) {
  // update locally and send reorder request
  // remove from source
  const from = columns.value.find(c => c.id === fromColumnId)
  const to = columns.value.find(c => c.id === toColumnId)
  if (!from || !to) return
  const idx = from.cards.findIndex(x => x.id === cardId)
  if (idx === -1) return
  const [card] = from.cards.splice(idx,1)
  card.kanban_column_id = toColumnId
  to.cards.splice(toPosition ?? to.cards.length, 0, card)

  // build reorder payload: flatten all cards with positions
  const payload = []
  columns.value.forEach(c => {
    c.cards.forEach((card, i) => payload.push({ id: card.id, kanban_column_id: c.id, position: i }))
  })
  await api.reorderCards(payload)
}

onMounted(() => { loadBoard() })
</script>

<style scoped>
.kanban-columns { display:flex; align-items:flex-start; }
.kanban-column-card { min-width: 300px; }
.kanban-add-column { min-width: 200px; }
.kanban-board { max-width: 100%; }
.lightbox-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.65);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1100;
  padding: 16px;
}

.lightbox-body {
  width: 100%;
  max-width: 960px;
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 6px 24px rgba(0, 0, 0, 0.2);
}

.lightbox-header {
  padding-bottom: 16px;
}

.lightbox-actions {
  padding-top: 12px;
  padding-bottom: 12px;
  border-top: 1px solid #e9ecef;
  border-bottom: 1px solid #e9ecef;
}

.lightbox-content {
  width: 100%;
  min-height: 320px;
  max-height: 70vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 6px;
  overflow: auto;
  margin: 16px 0;
  position: relative;
}

.lightbox-content img {
  max-width: none;
  max-height: none;
  object-fit: contain;
  transition: transform 0.2s ease;
  user-select: none;
}

.lightbox-footer {
  padding-top: 16px;
  border-top: 1px solid #e9ecef;
}

.file-frame {
  width: 100%;
  height: 70vh;
  border: none;
}
</style>
