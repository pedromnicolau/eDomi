<template>
  <footer class="site-footer">
    <div class="container py-4">
      <div class="row align-items-center">
        <div class="col-md-4 mb-2 mb-md-0">
          <div class="logo d-flex align-items-center gap-2">
            <img :src="logoSrc" class="logo-mark" alt="eDomi" />
            <div>
              <div class="fw-bold">eDomi</div>
              <div class="small">Imobiliária • Tecnologia • Confiança</div>
            </div>
          </div>
        </div>

        <div class="col-md-4 text-center mb-2 mb-md-0">
          <div class="small">© <strong>eDomi</strong> — Todos os direitos reservados</div>
          <p>CNPJ: 62.453.975/0001-22</p>
        </div>

        <div class="col-md-4 text-md-end">
          <router-link to="/privacy" class="link-footer me-3">Política de Privacidade</router-link>
          <router-link to="/terms" class="link-footer me-3">Termos de Uso</router-link>
          <a class="link-footer" href="/contact">Contato</a>
        </div>
      </div>
    </div>
  </footer>
</template>

<script setup>
/* filepath: /home/pedro/fatec/eDomi/app/frontend/components/Footer.vue */

/* novo: usar binding dinâmico para o logo */
const logoSrc = '/icon.png'
</script>

<style scoped>
.site-footer {
  background: linear-gradient(180deg,#0f254a 0%, #102b55 100%);
  color: #fff;
  width: 100%;
  padding: 1.25rem 0;
}

.logo-mark {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  background: linear-gradient(135deg,#1A2E66 0%, #4ADE80 100%);
  display: inline-block;
}

.link-footer {
  color: rgba(255,255,255,0.9);
  text-decoration: none;
  font-size: .9rem;
}

.link-footer:hover { color: var(--bs-light); text-decoration: underline; }

@media (max-width: 576px) {
  .site-footer { text-align: center; }
}
</style>
