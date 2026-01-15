<template>
  <div class="modal-overlay" @click="closeOnBackdrop">
    <div class="modal-card card p-3" @click.stop>
      <div class="d-flex align-items-start mb-2">
        <h5 class="me-auto">{{ card && card.id ? 'Editar cartão' : 'Novo cartão' }}</h5>
        <div class="d-flex align-items-center gap-2">
          <div class="dropdown-container" ref="actionsRef">
            <button class="btn btn-sm btn-outline-secondary btn-actions" type="button" @click.stop="toggleActions">⋯</button>
            <div v-if="showActions" class="dropdown-menu-custom" @click.stop>
              <button class="dropdown-item" type="button" @click="duplicateCard">Duplicar</button>
              <div class="dropdown-divider"></div>
              <div class="dropdown-label">Mover para</div>
              <div class="move-list">
                <button
                  v-for="col in otherColumns"
                  :key="col.id"
                  class="dropdown-item"
                  type="button"
                  @click="moveToColumn(col)"
                >
                  {{ col.name }}
                </button>
                <div v-if="otherColumns.length === 0" class="dropdown-item text-muted" disabled>Nenhuma outra coluna</div>
              </div>
              <div class="dropdown-divider"></div>
              <button class="dropdown-item text-danger" type="button" @click="confirmDelete">Excluir</button>
            </div>
          </div>
          <button class="btn-close" type="button" @click="$emit('closed')" aria-label="Fechar"></button>
        </div>
      </div>

      <div>
        <input v-model="title" class="form-control mb-2" placeholder="Título" />
        <textarea v-model="description" class="form-control mb-2" rows="3" placeholder="Descrição"></textarea>

        <input v-model="clientName" class="form-control mb-2" placeholder="Nome do cliente" />

        <select v-model="propertyId" class="form-control mb-2">
          <option value="">Selecione um imóvel...</option>
          <option v-for="prop in properties" :key="prop.id" :value="prop.id">
            {{ prop.name }} - {{ prop.address }}
          </option>
        </select>

        <label class="form-label small">Anexos</label>
        
        <div v-if="existingAttachments.length > 0" class="mb-3">
          <div class="existing-attachments">
            <div v-for="(attachment, idx) in existingAttachments" :key="attachment.id" class="attachment-item">
              <button type="button" class="attachment-preview" @click.stop="openAttachmentLightbox(idx)">
                <img v-if="isImage(attachment.filename)" :src="attachment.url" :alt="attachment.filename" />
                <div v-else class="file-icon">
                  <span v-if="isPdf(attachment.filename)" class="pdf-badge">PDF</span>
                  <i v-else class="bi bi-file-earmark"></i>
                </div>
              </button>
              <button type="button" class="btn-remove" @click.stop="removeAttachment(attachment.id)" title="Remover">×</button>
              <div class="filename-text">{{ attachment.filename }}</div>
            </div>
          </div>
        </div>

        <div class="input-group mb-2">
          <input type="file" multiple @change="onFiles" class="form-control form-control-sm" ref="fileInput" />
          <button v-if="newFiles.length > 0" type="button" class="btn btn-sm btn-secondary" @click="clearFiles">Limpar</button>
        </div>

        <div v-if="newFiles.length > 0" class="mb-3">
          <label class="form-label small">Novos arquivos:</label>
          <div class="new-attachments">
            <div v-for="(file, idx) in newFiles" :key="idx" class="attachment-item">
              <div class="attachment-preview">
                <img v-if="isImage(file.name)" :src="getPreview(file)" :alt="file.name" />
                <div v-else class="file-icon">
                  <span v-if="isPdf(file.name)" class="pdf-badge">PDF</span>
                  <i v-else class="bi bi-file-earmark"></i>
                </div>
              </div>
              <button type="button" class="btn-remove" @click="removeNewFile(idx)" title="Remover">×</button>
              <div class="filename-text">{{ file.name }}</div>
            </div>
          </div>
        </div>

        <div class="mt-4">
          <div class="d-flex align-items-center mb-3">
            <label class="form-label small mb-0">Atividade</label>
            <span class="ms-2 text-muted small" v-if="loadingComments">Carregando...</span>
          </div>
          <div class="activity-container">
            <div v-if="activityItems.length === 0" class="text-muted small py-3 text-center">Sem atividades ainda.</div>
            
            <template v-else v-for="(item, index) in activityItems" :key="item.id">
              <!-- Comentário de usuário -->
              <div v-if="item.type === 'comment'" class="comment-card">
                <div class="comment-header">
                  <div class="user-avatar">{{ getInitials(item.user?.name) }}</div>
                  <div class="comment-info">
                    <div class="user-name">{{ item.user?.name || item.user?.email }}</div>
                    <div class="comment-time">{{ getTimeRelative(item.created_at) }}</div>
                  </div>
                </div>
                <div class="comment-body">{{ item.body }}</div>
                
                <!-- Reações e reactions -->
                <div v-if="item.reactions && item.reactions.length > 0" class="comment-reactions">
                  <div v-for="reaction in item.reactions.filter(r => r.type === 'emoji')" :key="reaction.emoji" class="reaction-badge">
                    {{ reaction.emoji }}
                  </div>
                </div>

                <div class="comment-actions">
                  <button 
                    class="action-btn" 
                    :class="{ 'liked': userLikes[item.id] }"
                    @click.stop="toggleLike(item)"
                  >
                    <i class="fa-solid fa-thumbs-up"></i>
                    <span v-if="item.likes_count > 0" class="count">{{ item.likes_count }}</span>
                  </button>
                  <div class="emoji-picker-wrapper">
                    <button class="action-btn" @click.stop="showEmojiPicker(item)">
                      <i class="fa-solid fa-face-smile"></i>
                    </button>
                    <div v-if="showingEmojiFor === item.id" class="emoji-picker">
                      <button 
                        v-for="emoji in emojis" 
                        :key="emoji"
                        class="emoji-btn"
                        @click.stop="addEmojiReaction(item, emoji)"
                      >
                        {{ emoji }}
                      </button>
                    </div>
                  </div>
                  <button class="action-btn" @click.stop="toggleReply(item)">
                    Responder
                  </button>
                </div>

                <!-- Respostas -->
                <div v-if="item.replies && item.replies.length > 0" class="comment-replies">
                  <div v-for="reply in item.replies" :key="reply.id" class="reply-card">
                    <div class="reply-header">
                      <div class="user-avatar-small">{{ getInitials(reply.user?.name) }}</div>
                      <div class="reply-info">
                        <div class="user-name-small">{{ reply.user?.name || reply.user?.email }}</div>
                        <div class="reply-time">{{ getTimeRelative(reply.created_at) }}</div>
                      </div>
                    </div>
                    <div class="reply-body">{{ reply.body }}</div>
                  </div>
                </div>

                <!-- Input de resposta -->
                <div v-if="replyingTo === item.id" class="reply-input-wrapper">
                  <div class="user-avatar-small">{{ getInitials(currentUserName) }}</div>
                  <div class="input-group input-group-sm">
                    <input
                      v-model="replyText"
                      type="text"
                      class="form-control"
                      placeholder="Escreva uma resposta..."
                      @keyup.enter.prevent="submitReply"
                    />
                    <button class="btn btn-primary" type="button" :disabled="!replyText.trim()" @click="submitReply">Responder</button>
                  </div>
                </div>
              </div>

              <!-- Atividade do sistema (criação/edição) -->
              <div v-else class="system-activity">
                <div class="activity-icon">
                  <i v-if="item.type === 'created'" class="fa-solid fa-plus-circle"></i>
                  <i v-else-if="item.type === 'edited'" class="fa-solid fa-pen"></i>
                </div>
                <div class="activity-content">
                  <div class="activity-text">
                    <span class="activity-user">{{ item.user?.name || item.user?.email || 'Sistema' }}</span>
                    <span v-if="item.type === 'created'">criou o cartão</span>
                    <span v-else-if="item.type === 'edited'">editou</span>
                  </div>
                  <div class="activity-time">{{ getTimeRelative(item.created_at) }}</div>
                </div>
              </div>

              <!-- Detalhes das edições -->
              <div v-if="item.type === 'edited' && item.fields && item.fields.length" class="edit-details">
                <div v-for="(field, fidx) in item.fields" :key="fidx" class="edit-field">
                  <div class="field-name">{{ field.name }}</div>
                  <div class="field-change">
                    <span class="old-value" v-if="field.old">de: <code>{{ truncate(field.old) }}</code></span>
                    <span class="arrow" v-if="field.old && field.new">→</span>
                    <span class="new-value" v-if="field.new">para: <code>{{ truncate(field.new) }}</code></span>
                  </div>
                </div>
              </div>
            </template>
          </div>

          <!-- Input de novo comentário -->
          <div class="comment-input-wrapper mt-3">
            <div class="user-avatar-input">{{ getInitials(currentUserName) }}</div>
            <div class="input-group input-group-sm">
              <input
                v-model="newComment"
                type="text"
                class="form-control"
                :placeholder="props.card?.id ? 'Deixe um comentário...' : 'Salve o cartão para comentar'"
                :disabled="!props.card?.id"
                @keyup.enter.prevent="submitComment"
              />
              <button class="btn btn-primary" type="button" :disabled="!props.card?.id || !newComment.trim()" @click="submitComment">Enviar</button>
            </div>
          </div>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onBeforeUnmount } from 'vue'
import * as api from '@/api/kanban'
import { getTimeRelative, getInitials } from '@/utils/timeHelper'

const props = defineProps({ card: Object, column: Object, columns: { type: Array, default: () => [] } })
const emit = defineEmits(['saved','closed','open-attachment','deleted','move-card','duplicate'])

const title = ref(props.card?.title || '')
const description = ref(props.card?.description || '')
const clientName = ref(props.card?.client_info?.name || '')
const newFiles = ref([])
const removedAttachmentIds = ref([])
const fileInput = ref(null)
const showActions = ref(false)
const actionsRef = ref(null)
const saveTimer = ref(null)
const isSaving = ref(false)
const comments = ref(props.card?.comments || [])
const newComment = ref('')
const loadingComments = ref(false)
const propertyId = ref(props.card?.property_id || '')
const properties = ref([])

const existingAttachments = computed(() => {
  if (!props.card?.attachments) return []
  return props.card.attachments.filter(a => !removedAttachmentIds.value.includes(a.id))
})

const otherColumns = computed(() => {
  if (!props.columns || !Array.isArray(props.columns)) return []
  return props.columns.filter(c => c.id !== props.column?.id)
})

const activityItems = computed(() => {
  const items = []
  
  // Adiciona evento de criação
  if (props.card?.created_at) {
    items.push({
      id: 'created',
      type: 'created',
      created_at: props.card.created_at,
      user: null
    })
  }
  
  // Adiciona histórico de edições
  if (props.card?.edit_history && Array.isArray(props.card.edit_history)) {
    props.card.edit_history.forEach((edit, idx) => {
      items.push({
        id: `edit-${idx}`,
        type: 'edited',
        created_at: edit.edited_at,
        user: edit.user,
        fields: edit.fields
      })
    })
  }
  
  // Adiciona comentários
  comments.value.forEach(comment => {
    items.push({
      ...comment,
      type: 'comment'
    })
  })
  
  // Ordena por data
  return items.sort((a, b) => new Date(a.created_at) - new Date(b.created_at))
})

watch(() => props.card, (card) => {
  title.value = card?.title || ''
  description.value = card?.description || ''
  clientName.value = card?.client_info?.name || ''
    propertyId.value = card?.property_id || ''
  comments.value = card?.comments || []
})

function onFiles(e) {
  newFiles.value = Array.from(e.target.files)
  scheduleAutoSave()
}

function clearFiles() {
  newFiles.value = []
  if (fileInput.value) fileInput.value.value = ''
  scheduleAutoSave()
}

function removeNewFile(idx) {
  newFiles.value.splice(idx, 1)
  scheduleAutoSave()
}

function removeAttachment(id) {
  removedAttachmentIds.value.push(id)
  scheduleAutoSave()
}

function isImage(filename) {
  const imageExts = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg']
  const ext = filename.split('.').pop().toLowerCase()
  return imageExts.includes(ext)
}

function isPdf(filename) {
  if (!filename) return false
  return filename.toLowerCase().endsWith('.pdf')
}

function getPreview(file) {
  return URL.createObjectURL(file)
}

function openAttachmentLightbox(idx) {
  emit('open-attachment', { attachments: existingAttachments.value, index: idx, cardId: props.card?.id })
}

async function closeOnBackdrop() {
  if (saveTimer.value) clearTimeout(saveTimer.value)
  await saveCard(true)
  emit('closed')
}

async function confirmDelete() {
  closeActions()
  if (!props.card?.id) return
  const sure = confirm('Excluir este cartão? Esta ação não pode ser desfeita.')
  if (!sure) return
  try {
    await api.deleteCard(props.card.id)
    emit('deleted', props.card.id)
    emit('closed')
  } catch (e) {
    alert('Erro ao excluir: ' + (e?.error || JSON.stringify(e)))
  }
}

function toggleActions() {
  showActions.value = !showActions.value
}

function closeActions() { showActions.value = false }

function handleClickOutside(e) {
  if (!showActions.value) return
  if (actionsRef.value && !actionsRef.value.contains(e.target)) {
    closeActions()
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
  loadComments()
  // Obter usuário atual
  fetch('/current_user')
    .then(res => res.json())
    .then(user => {
      currentUserId.value = user.id
      currentUserName.value = user.name || user.email
    })
    .catch(e => console.error('Erro ao obter usuário atual', e))
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleClickOutside)
  if (saveTimer.value) clearTimeout(saveTimer.value)
})

const scheduleAutoSave = () => {
  if (saveTimer.value) clearTimeout(saveTimer.value)
  saveTimer.value = setTimeout(() => saveCard(true), 600)
}

watch([title, description, clientName], scheduleAutoSave)

async function saveCard(silent = false) {
  if (!props.column) return
  const payload = {
    title: title.value,
    description: description.value,
    kanban_column_id: props.column.id,
    client_info: { name: clientName.value }
  }

  try {
    isSaving.value = true
    let saved
    if (props.card && props.card.id) {
      saved = await api.updateCard(
        props.card.id,
        payload,
        newFiles.value.length > 0 ? newFiles.value : null,
        removedAttachmentIds.value.length > 0 ? removedAttachmentIds.value : null
      )
    } else {
      saved = await api.createCard(payload, newFiles.value.length > 0 ? newFiles.value : null)
    }
    emit('saved', saved)
    emit('update-card', saved)
    // after first save of a new card, clear removed/new buffers
    if (saved?.id) {
      newFiles.value = []
      removedAttachmentIds.value = []
      if (fileInput.value) fileInput.value.value = ''
    }
    return saved
  } catch (e) {
    if (!silent) alert('Erro ao salvar: ' + (e?.error || JSON.stringify(e)))
    else console.error('Auto-save falhou', e)
  } finally {
    isSaving.value = false
  }
}

async function duplicateCard() {
  closeActions()
  const payload = {
    title: title.value || (props.card?.title || ''),
    description: description.value || (props.card?.description || ''),
    kanban_column_id: props.column.id,
    client_info: { name: clientName.value || props.card?.client_info?.name || '' }
  }
  try {
    const created = await api.createCard(payload)
    emit('duplicate', created)
  } catch (e) {
    alert('Erro ao duplicar: ' + (e?.error || JSON.stringify(e)))
  }
}

async function moveToColumn(col) {
  if (!col?.id) return
  closeActions()
  // garante que o card existe antes de mover
  const saved = await saveCard(true)
  const cardId = saved?.id || props.card?.id
  if (!cardId) return
  const payload = {
    title: title.value,
    description: description.value,
    kanban_column_id: col.id,
    client_info: { name: clientName.value }
  }
  try {
    const updated = await api.updateCard(cardId, payload)
    emit('move-card', { card: updated, toColumnId: col.id })
    emit('saved', updated)
    emit('update-card', updated)
  } catch (e) {
    alert('Erro ao mover: ' + (e?.error || JSON.stringify(e)))
  }
}

async function loadComments() {
  if (!props.card?.id) return
  try {
    loadingComments.value = true
    comments.value = await api.fetchComments(props.card.id)
  } catch (e) {
    console.error('Erro ao carregar comentários', e)
  } finally {
    loadingComments.value = false
  }
}

async function submitComment() {
  if (!props.card?.id) {
    await saveCard(true)
  }
  const cardId = props.card?.id || null
  if (!cardId) return
  if (!newComment.value.trim()) return
  try {
    const created = await api.addComment(cardId, newComment.value.trim())
    comments.value.push(created)
    emit('update-card', { ...(props.card || {}), id: cardId, comments: comments.value })
    newComment.value = ''
  } catch (e) {
    alert('Erro ao comentar: ' + (e?.error || JSON.stringify(e)))
  }
}

function formatDate(iso) {
  if (!iso) return ''
  try {
    const d = new Date(iso)
    if (isNaN(d)) return iso
    const dd = String(d.getDate()).padStart(2, '0')
    const mm = String(d.getMonth() + 1).padStart(2, '0')
    const yyyy = d.getFullYear()
    const hh = String(d.getHours()).padStart(2, '0')
    const min = String(d.getMinutes()).padStart(2, '0')
    return `${dd}/${mm}/${yyyy} ${hh}:${min}`
  } catch (e) {
    return iso
  }
}

function truncate(value, len = 50) {
  if (!value) return ''
  const str = String(Array.isArray(value) ? value.join(', ') : value)
  return str.length > len ? str.substring(0, len) + '...' : str
}

const currentUserName = ref('Você')

const userLikes = computed(() => {
  const likes = {}
  comments.value.forEach(c => {
    const userLiked = c.reactions?.some(r => r.type === 'like' && r.user_id === currentUserId.value) || false
    likes[c.id] = userLiked
  })
  return likes
})

const currentUserId = ref(null)

async function toggleLike(comment) {
  try {
    if (userLikes.value[comment.id]) {
      const updated = await api.unlikeComment(comment.id)
      const idx = comments.value.findIndex(c => c.id === comment.id)
      if (idx >= 0) comments.value[idx] = updated
    } else {
      const updated = await api.likeComment(comment.id)
      const idx = comments.value.findIndex(c => c.id === comment.id)
      if (idx >= 0) comments.value[idx] = updated
    }
  } catch (e) {
    alert('Erro ao atualizar like: ' + (e?.error || JSON.stringify(e)))
  }
}

const showingEmojiFor = ref(null)
const emojis = ['👍', '❤️', '😂', '😮', '😢', '🔥']

function showEmojiPicker(comment) {
  showingEmojiFor.value = showingEmojiFor.value === comment.id ? null : comment.id
}

async function addEmojiReaction(comment, emoji) {
  try {
    const updated = await api.addReaction(comment.id, emoji)
    const idx = comments.value.findIndex(c => c.id === comment.id)
    if (idx >= 0) comments.value[idx] = updated
    showingEmojiFor.value = null
  } catch (e) {
    alert('Erro ao adicionar emoji: ' + (e?.error || JSON.stringify(e)))
  }
}

const replyingTo = ref(null)
const replyText = ref('')

function toggleReply(comment) {
  if (replyingTo.value === comment.id) {
    replyingTo.value = null
    replyText.value = ''
  } else {
    replyingTo.value = comment.id
    replyText.value = ''
  }
}

async function submitReply() {
  if (!replyingTo.value || !replyText.value.trim()) return
  try {
    const reply = await api.addReply(props.card.id, replyingTo.value, replyText.value.trim())
    const parentIdx = comments.value.findIndex(c => c.id === replyingTo.value)
    if (parentIdx >= 0) {
      if (!comments.value[parentIdx].replies) comments.value[parentIdx].replies = []
      comments.value[parentIdx].replies.push(reply)
    }
    replyingTo.value = null
    replyText.value = ''
  } catch (e) {
    alert('Erro ao responder: ' + (e?.error || JSON.stringify(e)))
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-card {
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
  background: white;
  border-radius: 4px;
}

.dropdown-container {
  position: relative;
}

.btn-actions {
  font-size: 16px;
  line-height: 1;
  padding: 0.2rem 0.4rem;
  letter-spacing: 1.5px;
  font-weight: bold;
}

.dropdown-menu-custom {
  position: absolute;
  right: 0;
  top: 100%;
  background: white;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 1050;
  min-width: 180px;
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

.dropdown-item.text-muted {
  cursor: default;
}

.comments-box {
  max-height: 200px;
  overflow-y: auto;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  padding: 8px 10px;
  background: #f8f9fa;
}

.activity-container {
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-height: 400px;
  overflow-y: auto;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  padding: 12px;
  background: #fff;
}

.comment-card {
  background: #f8f9fa;
  border-radius: 4px;
  padding: 12px;
  border: 1px solid #dee2e6;
}

.comment-header {
  display: flex;
  gap: 10px;
  margin-bottom: 8px;
}

.user-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #0d6efd;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 12px;
  flex-shrink: 0;
}

.comment-info {
  flex: 1;
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  gap: 8px;
}

.user-name {
  font-weight: 600;
  font-size: 14px;
  color: #212529;
}

.comment-time {
  font-size: 12px;
  color: #6c757d;
  white-space: nowrap;
}

.comment-body {
  font-size: 14px;
  line-height: 1.5;
  color: #495057;
  margin-bottom: 8px;
}

.comment-actions {
  display: flex;
  gap: 12px;
  padding-top: 8px;
  border-top: 1px solid #e9ecef;
}

.action-btn {
  background: none;
  border: none;
  color: #6c757d;
  cursor: pointer;
  font-size: 13px;
  display: flex;
  align-items: center;
  gap: 4px;
  transition: color 0.2s;
  padding: 0;
}

.action-btn:hover {
  color: #0d6efd;
}

.action-btn .count {
  font-size: 11px;
}

.action-btn.liked {
  color: #0d6efd;
  font-weight: bold;
}

.emoji-picker-wrapper {
  position: relative;
}

.emoji-picker {
  position: absolute;
  bottom: 100%;
  right: 0;
  background: white;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  padding: 6px;
  display: flex;
  gap: 4px;
  flex-wrap: wrap;
  width: 150px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  z-index: 100;
  margin-bottom: 4px;
}

.emoji-btn {
  background: none;
  border: 1px solid #e9ecef;
  border-radius: 2px;
  padding: 4px 6px;
  cursor: pointer;
  font-size: 16px;
  flex: 1;
  min-width: 24px;
  transition: background 0.2s;
}

.emoji-btn:hover {
  background: #f0f0f0;
}

.comment-reactions {
  display: flex;
  gap: 4px;
  margin: 8px 0;
  flex-wrap: wrap;
}

.reaction-badge {
  background: #f0f0f0;
  border: 1px solid #dee2e6;
  border-radius: 12px;
  padding: 2px 6px;
  font-size: 14px;
  cursor: default;
}

.comment-replies {
  margin-top: 12px;
  border-left: 2px solid #dee2e6;
  padding-left: 8px;
}

.reply-card {
  background: white;
  border-radius: 3px;
  padding: 8px;
  margin-bottom: 8px;
  border: 1px solid #e9ecef;
}

.reply-card:last-child {
  margin-bottom: 0;
}

.reply-header {
  display: flex;
  gap: 8px;
  margin-bottom: 6px;
  align-items: center;
}

.user-avatar-small {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #6c757d;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 10px;
  flex-shrink: 0;
}

.reply-info {
  display: flex;
  gap: 6px;
  align-items: baseline;
}

.user-name-small {
  font-weight: 600;
  font-size: 12px;
  color: #212529;
}

.reply-time {
  font-size: 11px;
  color: #6c757d;
  white-space: nowrap;
}

.reply-body {
  font-size: 13px;
  color: #495057;
  line-height: 1.4;
}

.reply-input-wrapper {
  display: flex;
  gap: 8px;
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px solid #e9ecef;
}

.reply-input-wrapper .user-avatar-small {
  margin-top: 2px;
}

.system-activity {
  display: flex;
  gap: 8px;
  padding: 8px 0;
}

.activity-icon {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #e9ecef;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #6c757d;
  font-size: 12px;
  flex-shrink: 0;
}

.activity-content {
  flex: 1;
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  font-size: 13px;
  color: #6c757d;
}

.activity-text {
  display: flex;
  gap: 4px;
}

.activity-user {
  font-weight: 600;
  color: #495057;
}

.activity-time {
  font-size: 12px;
  color: #999;
  white-space: nowrap;
}

.edit-details {
  margin: 6px 0 0 32px;
  padding: 8px 8px;
  background: #f8f9fa;
  border-left: 2px solid #dee2e6;
  border-radius: 2px;
  font-size: 12px;
}

.edit-field {
  margin-bottom: 6px;
}

.edit-field:last-child {
  margin-bottom: 0;
}

.field-name {
  font-weight: 600;
  color: #495057;
  margin-bottom: 2px;
}

.field-change {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #6c757d;
  flex-wrap: wrap;
}

.old-value,
.new-value {
  display: flex;
  align-items: center;
  gap: 2px;
}

.old-value code,
.new-value code {
  background: #e9ecef;
  padding: 1px 4px;
  border-radius: 2px;
  font-size: 11px;
  color: #495057;
}

.arrow {
  color: #6c757d;
}

.comment-input-wrapper {
  display: flex;
  gap: 10px;
}

.user-avatar-input {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #0d6efd;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 12px;
  flex-shrink: 0;
  margin-top: 4px;
}

.comment-item {
  background: #e9ecef;
  border-radius: 4px;
  padding: 10px 12px;
}

.system-activity-item {
  padding: 6px 0;
}

.system-activity-body {
  font-size: 14px;
  line-height: 1.4;
  font-style: italic;
}

.dropdown-divider {
  height: 1px;
  margin: 4px 0;
  background: #e9ecef;
}

.dropdown-label {
  padding: 6px 12px;
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: #6c757d;
}

.move-list {
  max-height: 200px;
  overflow-y: auto;
}

.existing-attachments,
.new-attachments {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(80px, 1fr));
  gap: 12px;
  margin-bottom: 12px;
}

.attachment-item {
  position: relative;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  overflow: hidden;
  background: #f8f9fa;
  transition: transform 0.2s, box-shadow 0.2s;
}

.attachment-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.attachment-preview {
  width: 100%;
  height: 80px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: white;
  border-bottom: 1px solid #dee2e6;
  overflow: hidden;
  border: none;
  padding: 0;
  cursor: pointer;
}

.attachment-preview img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.file-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  background: #f8d7da;
  color: #b71c1c;
  font-weight: 700;
  font-size: 12px;
  letter-spacing: 0.5px;
}

.pdf-badge {
  font-size: 12px;
  line-height: 1;
}

.filename-text {
  padding: 4px 6px;
  font-size: 11px;
  color: #495057;
  word-break: break-word;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  line-clamp: 2;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  line-height: 1.2;
}

.btn-remove {
  position: absolute;
  top: -8px;
  right: -8px;
  width: 28px;
  height: 28px;
  border: none;
  background: #dc3545;
  color: white;
  border-radius: 50%;
  cursor: pointer;
  font-size: 18px;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.2s;
}

.btn-remove:hover {
  background: #c82333;
}

.input-group {
  display: flex;
  gap: 8px;
}

.input-group .form-control {
  flex: 1;
}
</style>
