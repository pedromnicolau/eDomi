<template>
  <div class="filter-card card p-3 mb-3">
    <div class="row g-2 align-items-end">
      <div class="col-sm-4 col-md-2">
        <label class="form-label small">Cidade</label>
        <input v-model="local.city" class="form-control form-control-sm" placeholder="São Paulo" />
      </div>

      <div class="col-sm-4 col-md-2">
        <label class="form-label small">Estado</label>
        <input v-model="local.state" class="form-control form-control-sm" placeholder="SP" maxlength="2" />
      </div>

      <div class="col-sm-4 col-md-2">
        <label class="form-label small">Tipo</label>
        <select v-model="local.property_type" class="form-select form-select-sm">
          <option value="">Qualquer</option>
          <option value="house">Casa</option>
          <option value="apartment">Apartamento</option>
          <option value="land">Terreno</option>
          <option value="commercial">Comencial</option>
        </select>
      </div>

      <div class="col-sm-6 col-md-2">
        <label class="form-label small">Quartos</label>
        <select v-model.number="local.bedrooms" class="form-select form-select-sm">
          <option :value="null">Qualquer</option>
          <option v-for="n in 6" :key="n" :value="n">{{ n }}+</option>
        </select>
      </div>

      <div class="col-sm-6 col-md-2">
        <label class="form-label small">Banheiros</label>
        <select v-model.number="local.bathrooms" class="form-select form-select-sm">
          <option :value="null">Qualquer</option>
          <option v-for="n in 6" :key="n" :value="n">{{ n }}+</option>
        </select>
      </div>

      <div class="col-sm-6 col-md-2">
        <label class="form-label small">Vagas</label>
        <select v-model.number="local.parking_spaces" class="form-select form-select-sm">
          <option :value="null">Qualquer</option>
          <option v-for="n in 6" :key="n" :value="n">{{ n }}+</option>
        </select>
      </div>

      <div class="col-sm-6 col-md-2">
        <label class="form-label small">Mobiliado</label>
        <select v-model="local.furnished" class="form-select form-select-sm">
          <option value="">Qualquer</option>
          <option value="true">Sim</option>
          <option value="false">Não</option>
        </select>
      </div>

      <div class="col-sm-6 col-md-2">
        <label class="form-label small">Preço (min)</label>
        <input
          :value="formatBRL(local.min_price)"
          @input="onMinInput"
          @blur="onBlurFix('min')"
          class="form-control form-control-sm"
          placeholder="R$ 0,00"
        />
      </div>

      <div class="col-sm-6 col-md-2">
        <label class="form-label small">Preço (max)</label>
        <input
          :value="formatBRL(local.max_price)"
          @input="onMaxInput"
          @blur="onBlurFix('max')"
          class="form-control form-control-sm"
          placeholder="R$ 0,00"
        />
      </div>

      <div class="col-12 col-md-4 d-flex gap-2">
        <button class="btn btn-sm btn-apply" @click="apply">Aplicar</button>
        <button class="btn btn-sm btn-outline-secondary" @click="reset">Limpar</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive } from 'vue'
const emit = defineEmits(['apply-filters','reset-filters'])

const local = reactive({
  city: '',
  state: '',
  property_type: '',
  bedrooms: null,
  bathrooms: null,
  parking_spaces: null,
  furnished: '',
  min_price: null,
  max_price: null,
  min_area: null,
  max_area: null
})

const onlyDigits = (s = '') => (s || '').toString().replace(/\D/g, '')

// Converte string com apenas dígitos para number (assume últimos 2 dígitos = centavos)
const digitsToNumber = (digits) => {
  if (!digits) return null
  // remove zeros iniciais
  digits = digits.replace(/^0+/, '') || '0'
  const v = parseInt(digits, 10)
  return v / 100.0
}

const formatBRL = (value) => {
  if (value === null || value === undefined || Number.isNaN(Number(value))) return ''
  try {
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(Number(value))
  } catch {
    return String(value)
  }
}

// handlers para inputs
const onMinInput = (e) => {
  const v = e.target.value || ''
  const digits = onlyDigits(v)
  const num = digitsToNumber(digits)
  local.min_price = num
  // reformat immediate
  e.target.value = num == null ? '' : formatBRL(num)
}

const onMaxInput = (e) => {
  const v = e.target.value || ''
  const digits = onlyDigits(v)
  const num = digitsToNumber(digits)
  local.max_price = num
  e.target.value = num == null ? '' : formatBRL(num)
}

// on blur, if empty set null; else ensure formatting
const onBlurFix = (which) => {
  if (which === 'min') {
    if (local.min_price === null) return
    // keep as number; the displayed value is controlled by :value
  } else {
    if (local.max_price === null) return
  }
}

const apply = () => {
  // emit apenas campos preenchidos (null/empty são ignorados no filtro)
  // clone simples para evitar reatividade profunda
  const payload = {
    city: local.city || '',
    state: local.state || '',
    property_type: local.property_type || '',
    bedrooms: local.bedrooms ?? null,
    bathrooms: local.bathrooms ?? null,
    parking_spaces: local.parking_spaces ?? null,
    furnished: local.furnished || '',
    min_price: local.min_price, // Number or null
    max_price: local.max_price,
    min_area: local.min_area ?? null,
    max_area: local.max_area ?? null
  }
  emit('apply-filters', payload)
}

const reset = () => {
  local.city = ''
  local.state = ''
  local.property_type = ''
  local.bedrooms = null
  local.bathrooms = null
  local.parking_spaces = null
  local.furnished = ''
  local.min_price = null
  local.max_price = null
  local.min_area = null
  local.max_area = null
  emit('reset-filters')
}
</script>

<style scoped>
.filter-card { background: #fff; border-radius: .5rem; box-shadow: 0 6px 18px rgba(10,20,60,0.06); }
.form-label.small { font-size: .75rem; color: #333; }

/* botão aplicar verde */
.btn-apply {
  background: #4ADE80;       /* verde */
  color: #07203a !important; /* força a cor do texto */
  border: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 6px 18px rgba(10, 20, 60, 0.06);
  transition: transform .16s cubic-bezier(.2,.8,.2,1), box-shadow .16s ease;
  will-change: transform;
  text-decoration: none;
}

.btn-apply:hover,
.btn-apply:focus {
  color: #07203a !important;
  background: #4ADE80;
  transform: scale(1.06);
  box-shadow: 0 18px 40px rgba(10, 20, 60, 0.12);
}

.btn-apply:active {
  color: #07203a !important;
  background: #3FD271;
  transform: scale(0.98);
}

/* botão limpar */
.btn-outline-secondary {
  background: grey;
  color: white;
  border: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 6px 18px rgba(10, 20, 60, 0.06);
  transition: transform .16s cubic-bezier(.2,.8,.2,1), box-shadow .16s ease;
  will-change: transform;
  text-decoration: none;
}

.btn-outline-secondary:hover,
.btn-outline-secondary:focus {
  color: white !important;
  background: grey;
  transform: scale(1.06);
  box-shadow: 0 18px 40px rgba(10, 20, 60, 0.12);
}

.btn-outline-secondary:active {
  color: white !important;
  background: grey;
  transform: scale(0.98);
}
</style>
