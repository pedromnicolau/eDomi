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
          <option value="house">House</option>
          <option value="apartment">Apartment</option>
          <option value="land">Land</option>
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
        <input v-model.number="local.min_price" type="number" class="form-control form-control-sm" placeholder="R$" />
      </div>

      <div class="col-sm-6 col-md-2">
        <label class="form-label small">Preço (max)</label>
        <input v-model.number="local.max_price" type="number" class="form-control form-control-sm" placeholder="R$" />
      </div>

      <div class="col-sm-6 col-md-2">
        <label class="form-label small">Área (m² min)</label>
        <input v-model.number="local.min_area" type="number" class="form-control form-control-sm" />
      </div>

      <div class="col-sm-6 col-md-2">
        <label class="form-label small">Área (m² max)</label>
        <input v-model.number="local.max_area" type="number" class="form-control form-control-sm" />
      </div>

      <div class="col-12 col-md-4 d-flex gap-2">
        <button class="btn btn-sm btn-primary" @click="apply">Aplicar</button>
        <button class="btn btn-sm btn-outline-secondary" @click="reset">Limpar</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, toRefs } from 'vue'
const props = {}
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

const apply = () => {
  // emit apenas campos preenchidos (null/empty são ignorados no filtro)
  emit('apply-filters', { ...local })
}
const reset = () => {
  Object.keys(local).forEach(k => local[k] = (typeof local[k] === 'number' ? null : ''))
  local.bedrooms = null
  local.bathrooms = null
  local.parking_spaces = null
  emit('reset-filters')
}
</script>

<style scoped>
.filter-card { background: #fff; border-radius: .5rem; box-shadow: 0 6px 18px rgba(10,20,60,0.06); }
.form-label.small { font-size: .75rem; color: #333; }
</style>
