<template>
  <div class="kanban-board p-3">
    <div class="d-flex mb-3 align-items-center">
      <h2 class="me-3">Pipeline de Vendas</h2>
      <button class="btn btn-sm btn-primary" @click="openNewColumn">+ Nova Coluna</button>
      <div class="ms-auto">
        <button class="btn btn-outline-secondary btn-sm" @click="refresh">Atualizar</button>
      </div>
    </div>

    <div class="kanban-columns d-flex gap-3 overflow-auto" ref="board">
      <div v-for="col in columns" :key="col.id" class="kanban-column-card">
        <KanbanColumn :column="col" @update-column="onUpdateColumn" @delete-column="onDeleteColumn" @create-card="onCreateCard" @move-card="onMoveCard" />
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
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import KanbanColumn from './KanbanColumn.vue'
import * as api from '@/api/kanban'

const columns = ref([])
const addingColumn = ref(false)
const newColumnName = ref('')
const newColumnColor = ref('#7c8cff')

async function loadBoard() {
  // For simplicity we fetch the first board or create a default one
  const boards = await api.fetchBoards()
  let board = boards[0]
  if (!board) {
    board = await api.createBoard({ name: 'Pipeline de Vendas' })
  } else {
    board = await api.fetchBoard(board.id)
  }
  columns.value = board.columns || []
}

function refresh() { loadBoard() }

function openNewColumn() { addingColumn.value = true }
function cancelNewColumn() { addingColumn.value = false; newColumnName.value = '' }

async function createColumn() {
  if (!newColumnName.value.trim()) return
  const payload = { name: newColumnName.value.trim(), color: newColumnColor.value, kanban_board_id: columns.value[0]?.kanban_board_id }
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
  const col = columns.value.find(c => c.id === columnId)
  if (col) col.cards.push(card)
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
</style>
