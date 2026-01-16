<template>
  <div class="phone-input-wrapper">
    <label v-if="label" class="form-label">{{ label }}</label>
    <div class="phone-input-group">
      <select 
        v-model="selectedCountry" 
        class="country-select"
        :class="{ 'is-invalid': error }"
        @change="handleCountryChange"
      >
        <option v-for="country in countries" :key="country.code" :value="country.code">
          {{ country.flag }} {{ country.dial }}
        </option>
      </select>
      <input 
        :value="modelValue"
        type="tel"
        class="form-control phone-input"
        :class="{ 'is-invalid': error }"
        :placeholder="placeholder"
        :maxlength="maxLength"
        @input="handleInput"
        @blur="handleBlur"
      />
    </div>
    <div v-if="error" class="invalid-feedback d-block">
      {{ error }}
    </div>
    <div v-if="hint" class="form-text small">{{ hint }}</div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  },
  label: {
    type: String,
    default: ''
  },
  placeholder: {
    type: String,
    default: ''
  },
  hint: {
    type: String,
    default: ''
  },
  error: {
    type: String,
    default: ''
  },
  defaultCountry: {
    type: String,
    default: '+55'
  }
})

const emit = defineEmits(['update:modelValue', 'update:error'])

const countries = [
  { code: '+55', name: 'Brasil', flag: '🇧🇷', dial: '+55', format: 'BR' },
  { code: '+1', name: 'EUA/Canadá', flag: '🇺🇸', dial: '+1', format: 'US' },
  { code: '+44', name: 'Reino Unido', flag: '🇬🇧', dial: '+44', format: 'UK' },
  { code: '+351', name: 'Portugal', flag: '🇵🇹', dial: '+351', format: 'PT' },
  { code: '+34', name: 'Espanha', flag: '🇪🇸', dial: '+34', format: 'ES' },
  { code: '+33', name: 'França', flag: '🇫🇷', dial: '+33', format: 'FR' },
  { code: '+49', name: 'Alemanha', flag: '🇩🇪', dial: '+49', format: 'DE' },
  { code: '+39', name: 'Itália', flag: '🇮🇹', dial: '+39', format: 'IT' },
  { code: '+86', name: 'China', flag: '🇨🇳', dial: '+86', format: 'CN' },
  { code: '+81', name: 'Japão', flag: '🇯🇵', dial: '+81', format: 'JP' },
  { code: '+54', name: 'Argentina', flag: '🇦🇷', dial: '+54', format: 'AR' },
  { code: '+52', name: 'México', flag: '🇲🇽', dial: '+52', format: 'MX' }
]

const selectedCountry = ref(props.defaultCountry)

// Detectar país do número existente
watch(() => props.modelValue, (newValue) => {
  if (newValue) {
    const digits = newValue.replace(/\D/g, '')
    for (const country of countries) {
      const code = country.code.replace('+', '')
      if (digits.startsWith(code)) {
        selectedCountry.value = country.code
        break
      }
    }
  }
}, { immediate: true })

const maxLength = computed(() => {
  switch (selectedCountry.value) {
    case '+55': return 19 // +55 (00) 00000-0000
    case '+1': return 17  // +1 (000) 000-0000
    default: return 20
  }
})

const placeholder = computed(() => {
  if (props.placeholder) return props.placeholder
  
  switch (selectedCountry.value) {
    case '+55': return '(00) 00000-0000'
    case '+1': return '(000) 000-0000'
    case '+351': return '000 000 000'
    case '+44': return '00000 000000'
    default: return 'Número de telefone'
  }
})

function handleCountryChange() {
  // Limpar o número quando mudar de país
  const digits = props.modelValue.replace(/\D/g, '')
  
  // Remove código de país antigo se existir
  let cleanDigits = digits
  for (const country of countries) {
    const code = country.code.replace('+', '')
    if (cleanDigits.startsWith(code)) {
      cleanDigits = cleanDigits.substring(code.length)
      break
    }
  }
  
  // Formata com novo país
  formatAndEmit(cleanDigits)
}

function handleInput(e) {
  let value = e.target.value
  let digits = value.replace(/\D/g, '')
  
  // Remove código do país se o usuário digitou
  const selectedCode = selectedCountry.value.replace('+', '')
  if (digits.startsWith(selectedCode)) {
    digits = digits.substring(selectedCode.length)
  }
  
  formatAndEmit(digits)
}

function handleBlur() {
  validatePhone()
}

function formatAndEmit(digits) {
  let formatted = ''
  
  switch (selectedCountry.value) {
    case '+55': // Brasil
      if (digits.length <= 2) {
        formatted = digits.length > 0 ? `(${digits}` : digits
      } else if (digits.length <= 6) {
        formatted = `(${digits.substring(0, 2)}) ${digits.substring(2)}`
      } else if (digits.length <= 10) {
        const ddd = digits.substring(0, 2)
        const part1 = digits.substring(2, 6)
        const part2 = digits.substring(6, 10)
        formatted = `(${ddd}) ${part1}${part2 ? '-' + part2 : ''}`
      } else {
        const ddd = digits.substring(0, 2)
        const part1 = digits.substring(2, 7)
        const part2 = digits.substring(7, 11)
        formatted = `(${ddd}) ${part1}${part2 ? '-' + part2 : ''}`
      }
      break
      
    case '+1': // EUA/Canadá
      if (digits.length <= 3) {
        formatted = digits.length > 0 ? `(${digits}` : digits
      } else if (digits.length <= 6) {
        formatted = `(${digits.substring(0, 3)}) ${digits.substring(3)}`
      } else {
        const area = digits.substring(0, 3)
        const part1 = digits.substring(3, 6)
        const part2 = digits.substring(6, 10)
        formatted = `(${area}) ${part1}${part2 ? '-' + part2 : ''}`
      }
      break
      
    case '+351': // Portugal
      if (digits.length <= 3) {
        formatted = digits
      } else if (digits.length <= 6) {
        formatted = `${digits.substring(0, 3)} ${digits.substring(3)}`
      } else {
        formatted = `${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6, 9)}`
      }
      break
      
    case '+44': // Reino Unido
      if (digits.length <= 5) {
        formatted = digits
      } else {
        formatted = `${digits.substring(0, 5)} ${digits.substring(5, 11)}`
      }
      break
      
    default: // Outros países - formato genérico
      formatted = digits.replace(/(\d{3})(?=\d)/g, '$1 ').trim()
  }
  
  // Adiciona código do país ao valor final
  const fullValue = formatted ? `${selectedCountry.value} ${formatted}` : ''
  emit('update:modelValue', fullValue)
}

function validatePhone() {
  const phone = props.modelValue
  
  if (!phone || phone.trim() === '') {
    emit('update:error', '')
    return true
  }
  
  let digits = phone.replace(/\D/g, '')
  
  // Remove código do país
  const selectedCode = selectedCountry.value.replace('+', '')
  if (digits.startsWith(selectedCode)) {
    digits = digits.substring(selectedCode.length)
  }
  
  switch (selectedCountry.value) {
    case '+55': // Brasil
      if (digits.length < 10 || digits.length > 11) {
        emit('update:error', 'Telefone deve ter 10 ou 11 dígitos')
        return false
      }
      
      const ddd = parseInt(digits.substring(0, 2))
      if (ddd < 11 || ddd > 99) {
        emit('update:error', 'DDD inválido')
        return false
      }
      
      if (digits.length === 11 && digits[2] !== '9') {
        emit('update:error', 'Celular deve começar com 9 após o DDD')
        return false
      }
      
      if (digits.length === 10 && digits[2] === '9') {
        emit('update:error', 'Telefone fixo não pode começar com 9')
        return false
      }
      break
      
    case '+1': // EUA/Canadá
      if (digits.length !== 10) {
        emit('update:error', 'Telefone deve ter 10 dígitos')
        return false
      }
      break
      
    case '+351': // Portugal
      if (digits.length !== 9) {
        emit('update:error', 'Telefone deve ter 9 dígitos')
        return false
      }
      break
      
    case '+44': // Reino Unido
      if (digits.length < 10 || digits.length > 11) {
        emit('update:error', 'Telefone deve ter 10 ou 11 dígitos')
        return false
      }
      break
      
    default:
      if (digits.length < 8 || digits.length > 15) {
        emit('update:error', 'Número de telefone inválido')
        return false
      }
  }
  
  emit('update:error', '')
  return true
}

defineExpose({ validatePhone })
</script>

<style scoped>
.phone-input-wrapper {
  margin-bottom: 0;
}

.phone-input-group {
  display: flex;
  gap: 0.5rem;
}

.country-select {
  flex: 0 0 auto;
  min-width: 90px;
  padding: 0.375rem 0.75rem;
  font-size: 1rem;
  font-weight: 400;
  line-height: 1.5;
  color: #212529;
  background-color: #fff;
  background-clip: padding-box;
  border: 1px solid #ced4da;
  appearance: none;
  border-radius: 0.375rem;
  transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
  cursor: pointer;
}

.country-select:hover {
  border-color: #ced4da;
}

.country-select:focus {
  color: #212529;
  background-color: #fff;
  border-color: #86b7fe;
  outline: 0;
  box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
}

.country-select.is-invalid {
  border-color: #dc3545;
}

.country-select.is-invalid:focus {
  border-color: #dc3545;
  box-shadow: 0 0 0 0.25rem rgba(220, 53, 69, 0.25);
}

.phone-input {
  flex: 1;
  display: block;
  width: 100%;
  padding: 0.375rem 0.75rem;
  font-size: 1rem;
  font-weight: 400;
  line-height: 1.5;
  color: #212529;
  background-color: #fff;
  background-clip: padding-box;
  border: 1px solid #ced4da;
  appearance: none;
  border-radius: 0.375rem;
  transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.phone-input:focus {
  color: #212529;
  background-color: #fff;
  border-color: #86b7fe;
  outline: 0;
  box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
}

.phone-input.is-invalid {
  border-color: #dc3545;
}

.phone-input.is-invalid:focus {
  border-color: #dc3545;
  box-shadow: 0 0 0 0.25rem rgba(220, 53, 69, 0.25);
}

.invalid-feedback {
  color: #dc3545;
  font-size: 0.875em;
  margin-top: 0.25rem;
}

.form-text {
  margin-top: 0.25rem;
  font-size: 0.875em;
  color: #6c757d;
}
</style>
