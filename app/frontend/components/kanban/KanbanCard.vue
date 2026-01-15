<template>
  <div class="card p-2" @click="$emit('open-edit')">
    <div class="d-flex align-items-start gap-2">
      <div style="flex:1">
        <div class="fw-semibold">{{ card.title }}</div>
        <div class="text-muted small">{{ card.client_info?.name || '' }}</div>
        <div v-if="card.description" class="text-muted small mt-1" style="font-size: 0.8rem; line-height: 1.3;">{{ truncate(card.description, 60) }}</div>
        
        <div v-if="card.attachments && card.attachments.length > 0" class="attachments-grid mt-2">
          <button
            v-for="(attachment, idx) in card.attachments"
            :key="attachment.id"
            type="button"
            class="attachment-thumb"
            :title="attachment.filename"
            @click.stop="$emit('open-attachment', { attachments: card.attachments, index: idx, cardId: card.id })"
          >
            <img v-if="isImage(attachment.filename)" :src="attachment.url" :alt="attachment.filename" />
            <div v-else class="file-icon">
              <span v-if="isPdf(attachment.filename)" class="pdf-badge">PDF</span>
              <i v-else class="bi bi-file-earmark"></i>
            </div>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({ card: Object })
defineEmits(['open-edit', 'open-attachment'])

function truncate(text, length) {
  if (!text) return ''
  return text.length > length ? text.substring(0, length) + '...' : text
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
</script>

<style scoped>
.card {
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
}

.card:active {
  cursor: grabbing;
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.attachments-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(50px, 1fr));
  gap: 6px;
}

.attachment-thumb {
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid #dee2e6;
  border-radius: 3px;
  overflow: hidden;
  background: #f8f9fa;
  height: 50px;
  text-decoration: none;
  transition: transform 0.2s, box-shadow 0.2s;
  width: 100%;
  border: none;
  padding: 0;
}

.attachment-thumb:hover {
  transform: scale(1.05);
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
}

.attachment-thumb img {
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
</style>
