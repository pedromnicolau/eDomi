<template>
  <teleport to="body">
    <transition name="fade">
      <div v-if="show" class="confirm-overlay" @click.self="onCancel">
        <div class="confirm-dialog">
          <div class="confirm-header">
            <div class="confirm-icon" :class="iconClass">
              <svg v-if="type === 'danger'" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" viewBox="0 0 16 16">
                <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z"/>
                <path d="M7.002 11a1 1 0 1 1 2 0 1 1 0 0 1-2 0zM7.1 4.995a.905.905 0 1 1 1.8 0l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 4.995z"/>
              </svg>
              <svg v-else xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" viewBox="0 0 16 16">
                <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z"/>
                <path d="M5.255 5.786a.237.237 0 0 0 .241.247h.825c.138 0 .248-.113.266-.25.09-.656.54-1.134 1.342-1.134.686 0 1.314.343 1.314 1.168 0 .635-.374.927-.965 1.371-.673.489-1.206 1.06-1.168 1.987l.003.217a.25.25 0 0 0 .25.246h.811a.25.25 0 0 0 .25-.25v-.105c0-.718.273-.927 1.01-1.486.609-.463 1.244-.977 1.244-2.056 0-1.511-1.276-2.241-2.673-2.241-1.267 0-2.655.59-2.75 2.286zm1.557 5.763c0 .533.425.927 1.01.927.609 0 1.028-.394 1.028-.927 0-.552-.42-.94-1.029-.94-.584 0-1.009.388-1.009.94z"/>
              </svg>
            </div>
            <h5 class="confirm-title">{{ title }}</h5>
          </div>
          
          <div class="confirm-body">
            <p class="confirm-message">{{ message }}</p>
          </div>
          
          <div class="confirm-footer">
            <button class="btn btn-outline-secondary" type="button" @click="onCancel">
              {{ cancelText }}
            </button>
            <button class="btn" :class="confirmButtonClass" type="button" @click="onConfirm">
              {{ confirmText }}
            </button>
          </div>
        </div>
      </div>
    </transition>
  </teleport>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  show: { type: Boolean, default: false },
  title: { type: String, default: 'Confirmar ação' },
  message: { type: String, required: true },
  confirmText: { type: String, default: 'Confirmar' },
  cancelText: { type: String, default: 'Cancelar' },
  type: { type: String, default: 'danger' } // 'danger' or 'warning'
})

const emit = defineEmits(['confirm', 'cancel'])

const iconClass = computed(() => {
  return props.type === 'danger' ? 'icon-danger' : 'icon-warning'
})

const confirmButtonClass = computed(() => {
  return props.type === 'danger' ? 'btn-danger' : 'btn-warning'
})

function onConfirm() {
  emit('confirm')
}

function onCancel() {
  emit('cancel')
}
</script>

<style scoped>
.confirm-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(15, 23, 42, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 16px;
  backdrop-filter: blur(2px);
}

.confirm-dialog {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
  max-width: 440px;
  width: 100%;
  overflow: hidden;
}

.confirm-header {
  padding: 24px 24px 16px;
  text-align: center;
}

.confirm-icon {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px;
}

.icon-danger {
  background: #fee;
  color: #dc3545;
}

.icon-warning {
  background: #fff3cd;
  color: #ffc107;
}

.confirm-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2933;
  margin: 0;
}

.confirm-body {
  padding: 0 24px 24px;
  text-align: center;
}

.confirm-message {
  color: #52606d;
  font-size: 0.95rem;
  line-height: 1.5;
  margin: 0;
}

.confirm-footer {
  padding: 16px 24px;
  background: #f8f9fa;
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  border-top: 1px solid #e9ecef;
}

.confirm-footer .btn {
  min-width: 100px;
  font-weight: 500;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.fade-enter-active .confirm-dialog {
  animation: slideUp 0.2s ease;
}

.fade-leave-active .confirm-dialog {
  animation: slideDown 0.2s ease;
}

@keyframes slideUp {
  from {
    transform: translateY(20px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

@keyframes slideDown {
  from {
    transform: translateY(0);
    opacity: 1;
  }
  to {
    transform: translateY(20px);
    opacity: 0;
  }
}
</style>
