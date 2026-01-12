<template>
  <div class="d-flex justify-content-center py-5">
    <div class="card shadow-sm" style="max-width:560px; width:100%;">
      <div class="card-body">
        <h5 class="card-title mb-3">Editar perfil</h5>

        <form @submit.prevent="submitForm" class="needs-validation" novalidate>
          <div class="mb-3">
            <label class="form-label">Nome</label>
            <input name="user[name]" v-model="name" type="text" class="form-control" required />
          </div>

          <div class="mb-3">
            <label class="form-label">E‑mail</label>
            <input name="user[email]" v-model="email" type="email" class="form-control" required />
          </div>

                          <div class="mb-3">
                            <label class="form-label">Telefone</label>
                            <input
                              name="user[phone]"
                              v-model="phone"
                              type="tel"
                              class="form-control"
                              :class="{ 'is-invalid': phoneError }"
                              placeholder="Ex: (11) 98765-4321 ou +55 11 98765-4321"
                              pattern="\+?\d{10,15}"
                              required
                              @input="onPhoneInput"
                            />
                            <div class="form-text small">Informe seu número com DDD. Formatos aceitos: (11) 98765-4321 ou +55 11 98765-4321.</div>
                            <div v-if="phoneError" class="invalid-feedback small">{{ phoneError }}</div>
                          </div>

          <hr class="my-4">

          <div class="mb-3">
            <label class="form-label">Nova senha</label>
            <input name="user[password]" v-model="newPassword" type="password" class="form-control" minlength="6" />
            <div class="form-text small">Deixe em branco se não quiser alterar a senha. Mínimo 6 caracteres.</div>
          </div>

          <div class="mb-3">
            <label class="form-label">Confirme a nova senha</label>
            <input name="user[password_confirmation]" v-model="newPasswordConfirmation" type="password" class="form-control" minlength="6" />
            <div v-if="mismatch" class="text-danger small mt-1">As senhas não coincidem.</div>
          </div>

          <hr class="my-4">

          <div class="mb-3">
            <label class="form-label">Senha atual (necessária apenas se alterar senha)</label>
            <input name="user[current_password]" v-model="currentPassword" type="password" class="form-control" :required="newPassword.length > 0" />
            <div class="form-text small">Deixe em branco para atualizar apenas nome, e‑mail ou telefone.</div>
          </div>

          <div class="d-grid mb-2">
            <button type="submit" class="btn" :disabled="mismatch" style="background:#1A2E66; color:#fff;">Salvar alterações</button>
          </div>

          <div v-if="formError" class="alert alert-danger small mb-2" data-autoclose="false">{{ formError }}</div>
          <div v-if="formSuccess" class="alert alert-success small mb-2" data-autoclose="false">{{ formSuccess }}</div>
        </form>

        <hr/>
        <div class="mt-4 p-3 border border-danger rounded">
          <h6 class="text-danger mb-2">Zona de Perigo</h6>
          <p class="small text-muted mb-3">
            Excluir sua conta é uma ação permanente e não pode ser desfeita. 
            Todos os seus dados serão removidos permanentemente.
          </p>
          
          <button
            type="button"
            class="btn btn-outline-danger btn-sm"
            @click="showDeleteConfirmation = true"
            v-if="!showDeleteConfirmation"
          >
            Excluir minha conta
          </button>

          <!-- Modal de confirmação inline -->
          <div v-if="showDeleteConfirmation" class="mt-3">
            <div class="alert alert-danger mb-3">
              <strong>⚠️ Atenção!</strong> Esta ação é irreversível.
              Digite sua senha atual para confirmar a exclusão da sua conta.
            </div>

            <div class="mb-3">
              <label class="form-label small">Senha atual para confirmar</label>
              <input
                v-model="deletePassword"
                type="password"
                class="form-control form-control-sm"
                placeholder="Digite sua senha"
                @keyup.enter="confirmDelete"
              />
            </div>

            <div v-if="deleteError" class="text-danger small mb-2">{{ deleteError }}</div>
            <div v-if="blockedProperties.length" class="alert alert-warning small" data-autoclose="false">
              <div class="mb-2">
                <strong>Motivo:</strong> Existem imóveis associados à sua conta como corretor responsável.
              </div>
              <div class="mb-2">Transfira a responsabilidade destes imóveis para um <em>corretor</em> ou <em>administrador</em> antes de excluir sua conta:</div>
              <ul class="mb-2">
                <li v-for="p in blockedProperties" :key="p.id">
                  <router-link :to="`/properties/${p.id}/edit`" class="text-decoration-none">
                    #{{ p.id }} — {{ p.title || 'Imóvel sem título' }} (editar)
                  </router-link>
                </li>
              </ul>
              <div>
                Vá até cada imóvel e altere o campo “Corretor responsável”.</div>
            </div>

            <div class="d-flex gap-2">
              <button
                type="button"
                class="btn btn-danger btn-sm"
                @click="confirmDelete"
                :disabled="!deletePassword || deletingAccount"
              >
                <span v-if="deletingAccount">
                  <span class="spinner-border spinner-border-sm me-1"></span>
                  Excluindo...
                </span>
                <span v-else>Sim, excluir minha conta</span>
              </button>
              <button
                type="button"
                class="btn btn-outline-secondary btn-sm"
                @click="cancelDelete"
                :disabled="deletingAccount"
              >
                Cancelar
              </button>
            </div>
          </div>
        </div>

        <hr/>
        <div class="text-center small">
          <router-link to="/">Voltar</router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'

const csrf = ref(document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '')
const name = ref('')
const email = ref('')
const phone = ref('')
const currentPassword = ref('')
const user = ref(null)

const route = useRoute()

// Se o usuário veio do fluxo de agendamento, tornamos o telefone obrigatório
const requirePhone = computed(() => {
  try {
    const v = route.query.require_phone
    return String(v) === '1' || String(v) === 'true'
  } catch (e) { return false }
})

// Validação simples e prática de telefone:
// - remove quaisquer caracteres não numéricos
// - aceita números com ou sem código de país (ex: 11987654321 ou 5511987654321)
// - para BR: aceita 10 ou 11 dígitos (DDD + número). Se incluir código 55, aceita 12 ou 13.
const isValidPhone = (p) => {
  if (!p) return false
  const digits = String(p).replace(/\D/g, '')
  if (digits.length < 10 || digits.length > 13) return false
  // se tiver código do país (55), o restante deve ser 10 ou 11
  if (digits.startsWith('55')) {
    const rest = digits.slice(2)
    return rest.length === 10 || rest.length === 11
  }
  // sem código do país: 10 ou 11 dígitos aceitáveis
  return digits.length === 10 || digits.length === 11
}

// Formata telefone enquanto o usuário digita
const formatPhone = (digits, keepPlus) => {
  if (!digits) return ''
  // remove zeros à esquerda desnecessários
  let d = digits.replace(/^0+/, '')
  let prefix = ''
  if (d.startsWith('55')) {
    prefix = '+55 '
    d = d.slice(2)
  }

  // área (2 primeiros dígitos) quando disponíveis
  const area = d.slice(0, 2)
  const number = d.slice(2)

  let formattedNumber = ''
  if (!number) {
    // somente área parcial
    if (area) return prefix + (area.length === 2 ? `(${area})` : `(${area}`)
    return prefix + d
  }

  if (number.length <= 4) {
    formattedNumber = number
  } else {
    const last4 = number.slice(-4)
    const first = number.slice(0, number.length - 4)
    formattedNumber = `${first}-${last4}`
  }

  if (area) return prefix + `(${area}) ${formattedNumber}`
  return prefix + formattedNumber
}

const onPhoneInput = (e) => {
  try {
    const raw = e.target.value || ''
    const keepPlus = raw.trim().startsWith('+')
    const digits = raw.replace(/\D/g, '')
    phone.value = formatPhone(digits, keepPlus)
  } catch (err) {
    // fallback: não interrompe o typing
  }
}

// novos campos de senha
const newPassword = ref('')
const newPasswordConfirmation = ref('')

const mismatch = computed(() =>
  newPassword.value.length > 0 && newPasswordConfirmation.value.length > 0 && (newPassword.value !== newPasswordConfirmation.value)
)

const formError = ref('')
const formSuccess = ref('')
const phoneError = ref('')

// Estados para exclusão de conta
const showDeleteConfirmation = ref(false)
const deletePassword = ref('')
const deleteError = ref('')
const deletingAccount = ref(false)
const blockedProperties = ref([])

// busca usuário atual
onMounted(async () => {
  try {
    const res = await fetch('/current_user.json', {
      credentials: 'same-origin',
      headers: { 'Accept': 'application/json' }
    })
    if (res.ok) {
      const data = await res.json()
      if (data) {
        name.value = data.name || ''
        email.value = data.email || ''
        phone.value = data.phone || ''
      }
    }
  } catch (e) {
    // ignore
  }
})

// envio via fetch/AJAX
const submitForm = async () => {
  formError.value = ''
  formSuccess.value = ''
  phoneError.value = ''

  const changingPassword = newPassword.value.length > 0 || newPasswordConfirmation.value.length > 0
  if (changingPassword && !currentPassword.value) {
    formError.value = 'Informe sua senha atual para alterar a senha.'
    return
  }

  // valida telefone: obrigatório apenas se veio do agendamento; mas se preenchido sempre validar formato
  if (requirePhone.value && !phone.value) {
    phoneError.value = 'Telefone é obrigatório para agendar visitas.'
    return
  }
  if (phone.value) {
    if (!isValidPhone(phone.value)) {
      phoneError.value = 'Telefone inválido. Informe DDD + número (ex: 11987654321) ou com código +55.'
      return
    }
  }

  // validações de senha nova (se fornecida)
  if (newPassword.value && newPassword.value.length < 6) {
    formError.value = 'A nova senha deve ter no mínimo 6 caracteres.'
    return
  }

  if (mismatch.value) {
    formError.value = 'As novas senhas não coincidem.'
    return
  }

  try {
    // monta payload incluindo senha se informada
    const payload = {
      user: {
        name: name.value,
        email: email.value,
        phone: phone.value
      }
    }
    if (changingPassword) {
      payload.user.current_password = currentPassword.value
    }
    if (newPassword.value) {
      payload.user.password = newPassword.value
      payload.user.password_confirmation = newPasswordConfirmation.value
    }

    const res = await fetch('/users', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf.value
      },
      credentials: 'same-origin',
      body: JSON.stringify(payload)
     })

     const data = await res.json().catch(() => null)

    if (res.ok && data) {
       formSuccess.value = 'Perfil atualizado com sucesso.'
       currentPassword.value = ''
       newPassword.value = ''
       newPasswordConfirmation.value = ''
       // atualiza navbar
       if (user.value) {
         user.value.name = data.name
         user.value.email = data.email
       }
     } else {
       formError.value = (data && data.error) || 'Falha ao atualizar perfil.'
     }

  } catch (e) {
     formError.value = e.message || 'Erro ao atualizar perfil.'
   }
}

// Cancela processo de exclusão
const cancelDelete = () => {
  showDeleteConfirmation.value = false
  deletePassword.value = ''
  deleteError.value = ''
}

// Confirma e executa exclusão da conta
const confirmDelete = async () => {
  if (!deletePassword.value) {
    deleteError.value = 'Digite sua senha para confirmar.'
    return
  }

  deleteError.value = ''
  deletingAccount.value = true

  try {
    const res = await fetch('/users.json', {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-CSRF-Token': csrf.value
      },
      credentials: 'same-origin',
      body: JSON.stringify({
        user: {
          current_password: deletePassword.value
        }
      })
    })

    const data = await res.json().catch(() => null)

    if (res.ok) {
      // Redireciona para home após exclusão bem-sucedida
      try { localStorage.setItem('accountDeleted', '1') } catch {}
      window.location.href = '/'
    } else {
      deleteError.value = (data && (data.error || data.message)) || 'Erro ao excluir conta.'
      blockedProperties.value = (data && data.properties) || []
      deletingAccount.value = false
    }
  } catch (e) {
    deleteError.value = e.message || 'Erro ao excluir conta.'
    deletingAccount.value = false
  }
}
</script>

<style scoped>
.card-title { color:#1A2E66; font-weight:700; }
@media (max-width:576px){ .card{ margin:0 1rem; } }
</style>
