<template>
  <div class="kanban-board-shell">
    <div class="kanban-board p-3">
      <div class="kanban-board-header">
        <div class="d-flex align-items-center gap-3 flex-wrap">
          <div class="board-dropdown" :class="{ open: showBoardMenu }">
            <button class="btn board-selector-btn btn-sm d-flex align-items-center" type="button" @click.stop="toggleBoardMenu" :disabled="boardsLoading || boards.length === 0">
              <span class="text-truncate board-selector-label">{{ currentBoard?.name || 'Boards' }}</span>
              <svg :class="['caret-icon', { open: showBoardMenu }]" viewBox="0 0 16 16" aria-hidden="true">
                <path d="M4.5 6l3.5 4 3.5-4z" fill="currentColor" />
              </svg>
            </button>
            <div v-if="showBoardMenu" class="dropdown-menu show">
              <div v-if="boards.length === 0" class="dropdown-item text-muted small">Nenhum board</div>
              <div v-for="b in boards" :key="b.id" class="dropdown-item board-row d-flex align-items-center gap-2">
                <button class="board-select-btn flex-grow-1 text-start" type="button" @click.stop="selectBoard(b.id)">
                  <span class="text-truncate">{{ b.name }}</span>
                  <i v-if="currentBoard?.id === b.id" class="bi bi-check-lg text-success ms-2"></i>
                </button>
                <button class="btn btn-link btn-sm text-danger p-0 ms-1" type="button" @click.stop="onDeleteBoard(b.id)" :disabled="boardsLoading">
                  <i class="bi bi-trash"></i>
                </button>
              </div>
            </div>
          </div>

          <div class="d-flex align-items-center gap-2 flex-wrap">
            <div class="board-title-editable" @click="startEditBoard" :title="currentBoard ? 'Clique para renomear' : ''">
              <template v-if="!editingBoardName">
                <h4 class="board-title mb-0 text-truncate">{{ currentBoard?.name || '...' }}</h4>
              </template>
              <template v-else>
                <input
                  ref="boardNameInputRef"
                  v-model="editBoardName"
                  class="board-title-input"
                  @blur="handleBoardNameBlur"
                  @keyup.enter.prevent="handleBoardNameBlur"
                />
              </template>
            </div>
            <button v-if="currentBoard && !editingBoardName" class="board-delete-btn" type="button" @click.stop="onDeleteBoard(currentBoard.id)" :disabled="boardsLoading" title="Excluir board">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                <path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z"/>
                <path fill-rule="evenodd" d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4 4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z"/>
              </svg>
            </button>
          </div>
        </div>

        <div class="d-flex align-items-center gap-2 flex-wrap">
          <button class="btn btn-success btn-sm d-flex align-items-center gap-1" type="button" @click="openCreateBoardModal" :disabled="boardsLoading">
            <i class="bi bi-plus-lg"></i>
            <span>Novo board</span>
          </button>
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
  </div>

  <ConfirmDialog
    :show="confirmDialog.show"
    :title="confirmDialog.title"
    :message="confirmDialog.message"
    @confirm="confirmDialog.onConfirm"
    @cancel="confirmDialog.show = false"
  />

  <!-- Modal de criação de board -->
  <div v-if="showCreateBoardModal" class="modal-overlay" @click.self="closeCreateBoardModal">
    <div class="modal-dialog modal-md">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">Criar novo board</h5>
          <button type="button" class="btn-close" @click="closeCreateBoardModal" aria-label="Fechar"></button>
        </div>
        <form @submit.prevent="createNewBoard">
          <div class="modal-body">
            <label class="form-label">Nome do board</label>
            <input
              ref="newBoardNameInputRef"
              v-model="newBoardName"
              type="text"
              class="form-control"
              placeholder="Ex: Pipeline de Vendas"
              :disabled="createBoardLoading"
              required
            />
            <div v-if="createBoardError" class="text-danger small mt-2">{{ createBoardError }}</div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeCreateBoardModal" :disabled="createBoardLoading">Cancelar</button>
            <button type="submit" class="btn btn-success" :disabled="createBoardLoading || !newBoardName.trim()">
              <span v-if="createBoardLoading">Criando...</span>
              <span v-else>Criar board</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, nextTick } from 'vue'
import KanbanColumn from './KanbanColumn.vue'
import ConfirmDialog from '@/components/common/ConfirmDialog.vue'
import * as api from '@/api/kanban'

const boards = ref([])
const boardsLoading = ref(false)
const currentBoard = ref(null)
const columns = ref([])
const showCreateBoardModal = ref(false)
const newBoardName = ref('')
const newBoardNameInputRef = ref(null)
const createBoardError = ref('')
const createBoardLoading = ref(false)
const defaultColumns = [
  { name: 'A Fazer', color: '#6c757d' },
  { name: 'Em andamento', color: '#0d6efd' },
  { name: 'Concluído', color: '#198754' }
]
const showBoardMenu = ref(false)
const addingColumn = ref(false)
const newColumnName = ref('')
const newColumnColor = ref('#7c8cff')
const editingBoardName = ref(false)
const editBoardName = ref('')
const boardNameInputRef = ref(null)
const lightboxOpen = ref(false)
const lightboxItems = ref([])
const lightboxIndex = ref(0)
const zoomLevel = ref(1)
const baseZoom = ref(1)
const lightboxContentRef = ref(null)
const isDragging = ref(false)
const dragStart = ref({ x: 0, y: 0, scrollLeft: 0, scrollTop: 0 })

const confirmDialog = ref({
  show: false,
  title: '',
  message: '',
  onConfirm: null
})

async function initBoards() {
  boardsLoading.value = true
  try {
    boards.value = await api.fetchBoards()
    let target = boards.value[0]
    if (!target) {
      target = await api.createBoard({ name: 'Pipeline de Vendas' })
      boards.value = [ target ]
    }
    if (target?.id) await selectBoard(target.id)
  } finally {
    boardsLoading.value = false
  }
}

function toggleBoardMenu() {
  if (boardsLoading.value || boards.value.length === 0) return
  showBoardMenu.value = !showBoardMenu.value
}

async function selectBoard(boardId) {
  if (!boardId) return
  boardsLoading.value = true
  try {
    const board = await api.fetchBoard(boardId)
    currentBoard.value = board
    editBoardName.value = board?.name || ''
    editingBoardName.value = false
    columns.value = board?.columns || []
    if (columns.value.length === 0) {
      const createdColumns = await createDefaultColumns(board.id)
      columns.value = createdColumns
    }
    boards.value = boards.value.map(b => b.id === board.id ? { ...b, name: board.name } : b)
    showBoardMenu.value = false
  } finally {
    boardsLoading.value = false
  }
}

function openCreateBoardModal() {
  createBoardError.value = ''
  newBoardName.value = ''
  showCreateBoardModal.value = true
  nextTick(() => {
    if (newBoardNameInputRef.value) newBoardNameInputRef.value.focus()
  })
}

function closeCreateBoardModal() {
  showCreateBoardModal.value = false
  createBoardError.value = ''
  newBoardName.value = ''
}

async function createNewBoard() {
  createBoardError.value = ''
  const name = newBoardName.value.trim()
  if (!name) {
    createBoardError.value = 'Informe um nome para o board.'
    return
  }
  boardsLoading.value = true
  createBoardLoading.value = true
  try {
    const created = await api.createBoard({ name })
    boards.value.push(created)
    await selectBoard(created.id)
    showBoardMenu.value = false
    closeCreateBoardModal()
  } catch (e) {
    createBoardError.value = e?.message || 'Não foi possível criar o board.'
  } finally {
    createBoardLoading.value = false
    boardsLoading.value = false
  }
}

async function onDeleteBoard(boardId) {
  if (!boardId || boardsLoading.value) return
  
  confirmDialog.value = {
    show: true,
    title: 'Excluir board',
    message: 'Tem certeza que deseja excluir este board e todos os seus dados? Esta ação não pode ser desfeita.',
    onConfirm: async () => {
      confirmDialog.value.show = false
      boardsLoading.value = true
      try {
        await api.deleteBoard(boardId)
        boards.value = boards.value.filter(b => b.id !== boardId)
        if (currentBoard.value?.id === boardId) {
          if (boards.value.length > 0) {
            await selectBoard(boards.value[0].id)
          } else {
            const created = await api.createBoard({ name: 'Pipeline de Vendas' })
            boards.value = [ created ]
            await selectBoard(created.id)
          }
        }
        showBoardMenu.value = false
      } finally {
        boardsLoading.value = false
      }
    }
  }
}

async function createDefaultColumns(boardId) {
  const created = []
  for (const col of defaultColumns) {
    const c = await api.createColumn({ ...col, kanban_board_id: boardId })
    created.push(c)
  }
  return created
}

function startEditBoard() {
  if (!currentBoard.value) return
  editBoardName.value = currentBoard.value.name || ''
  editingBoardName.value = true
  nextTick(() => {
    if (boardNameInputRef.value) {
      boardNameInputRef.value.focus()
      boardNameInputRef.value.select()
    }
  })
}

async function saveBoardName() {
  if (!currentBoard.value) { editingBoardName.value = false; return }
  const name = editBoardName.value.trim()
  if (!name || name === currentBoard.value.name) {
    editBoardName.value = currentBoard.value.name || ''
    editingBoardName.value = false
    return
  }
  const updated = await api.updateBoard(currentBoard.value.id, { name })
  currentBoard.value = updated
  columns.value = updated.columns || []
  editBoardName.value = updated.name
  editingBoardName.value = false
  boards.value = boards.value.map(b => b.id === updated.id ? { ...b, name: updated.name } : b)
}

function handleBoardNameBlur() {
  saveBoardName()
}

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

onMounted(() => { initBoards() })

function handleClickOutside(event) {
  const dropdownEl = document.querySelector('.board-dropdown')
  if (dropdownEl && dropdownEl.contains(event.target)) return
  showBoardMenu.value = false
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
.kanban-board-shell {
  width: 80%;
  max-width: 1400px;
  margin: 0 auto;
}

.kanban-board-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 16px;
}

.board-title {
  font-size: 1.25rem;
  font-weight: 700;
  max-width: 380px;
  color: #212529;
}

.board-dropdown .dropdown-menu {
  max-height: 260px;
  overflow-y: auto;
}
.board-dropdown {
  position: relative;
}
.board-dropdown .dropdown-menu {
  position: absolute;
  display: block;
  min-width: 220px;
  z-index: 1050;
  margin-top: 4px;
}

.board-selector-btn {
  background: #fff;
  border: 1px solid #d0d7de;
  color: #1f2933;
  padding: 6px 32px 6px 10px;
  min-width: 180px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.04);
  transition: border-color 0.15s ease, box-shadow 0.15s ease, color 0.15s ease;
  position: relative;
}

.board-selector-btn:hover {
  border-color: #9bb1c7;
  box-shadow: 0 6px 16px rgba(0,0,0,0.08);
}

.board-selector-btn:disabled {
  background: #f5f6f7;
  color: #9aa3ad;
  box-shadow: none;
}

.board-selector-label {
  max-width: 220px;
  font-weight: 600;
  letter-spacing: 0.01em;
}

.caret-icon {
  width: 14px;
  height: 14px;
  color: #1f2933;
  transition: transform 0.2s ease;
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
}

.caret-icon.open {
  transform: rotate(180deg);
}

.board-dropdown .dropdown-menu {
  border: 1px solid #d0d7de;
  box-shadow: 0 10px 24px rgba(0,0,0,0.1);
  border-radius: 8px;
  padding: 6px 0;
}

.board-dropdown .dropdown-item {
  font-weight: 500;
}

.board-dropdown .dropdown-item:hover {
  background: #f2f6fb;
}

.board-row {
  padding: 6px 10px;
}

.board-select-btn {
  background: transparent;
  border: none;
  padding: 0;
  color: #1f2933;
  font-weight: 600;
}

.board-select-btn:hover {
  color: #0d6efd;
}

.board-title-button {
  background: transparent;
  border: none;
  padding: 0;
  display: inline-flex;
  align-items: center;
  cursor: pointer;
}

.board-title-button:disabled {
  cursor: not-allowed;
}

.board-title-editable {
  min-height: 32px;
  display: inline-flex;
  align-items: center;
}

.board-title-input {
  border: 1px solid #e7eaee;
  border-radius: 6px;
  height: 32px;
  padding: 4px 10px;
  font-size: 1rem;
  font-weight: 700;
  min-width: 240px;
  max-width: 380px;
  box-shadow: 0 2px 6px rgba(15, 23, 42, 0.04);
  background: #fdfdfd;
  transition: border-color 0.12s ease, box-shadow 0.12s ease;
  outline: none;
}

.board-title-input:focus {
  border-color: #a8b7c7;
  box-shadow: 0 3px 10px rgba(15, 23, 42, 0.06);
}

.board-delete-btn {
  background: transparent;
  border: none;
  padding: 6px 8px;
  color: #9aa3ad;
  cursor: pointer;
  transition: color 0.15s ease;
  font-size: 1rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.board-delete-btn svg {
  width: 16px;
  height: 16px;
}

.board-delete-btn:hover {
  color: #dc3545;
}

.board-delete-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.kanban-columns { display:flex; align-items:flex-start; }
.kanban-column-card { min-width: 300px; }
.kanban-add-column { min-width: 200px; }
.kanban-board { max-width: 100%; }
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1300;
  padding: 16px;
}

.modal-dialog {
  width: 90%;
  max-width: 520px;
  margin: 0 auto;
}

.modal-content {
  background: #ffffff;
  border-radius: 12px;
  box-shadow: 0 18px 48px rgba(15, 23, 42, 0.16);
  overflow: hidden;
}

.modal-header,
.modal-footer {
  padding: 1rem 1.25rem;
  border-color: #e9ecef;
}

.modal-body {
  padding: 1rem 1.25rem;
}

.modal-title {
  margin: 0;
  font-weight: 700;
  color: #1f2937;
}

.btn-close {
  background: none;
  border: none;
  font-size: 1.35rem;
  line-height: 1;
  opacity: 0.6;
  cursor: pointer;
  padding: 0;
}

.btn-close:hover { opacity: 1; }
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
