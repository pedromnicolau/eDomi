<template>
  <section class="about-page">
    <header class="hero">
      <div class="hero-bg" role="img" aria-label="Vista urbana de imóveis"></div>
      <div class="hero-overlay"></div>
      <div class="hero-inner container">
        <div class="hero-copy">
          <h1>Construindo o futuro do seu próximo lar</h1>
          <p class="lead">Tecnologia, transparência e atendimento humano para encontrar o imóvel ideal — seja para morar, investir ou empreender.</p>
          <div class="cta-group">
            <router-link to="/" class="btn-view-imoveis btn-cta">Ver Imóveis</router-link>
            <router-link to="/contact" class="btn-outline-cta">Fale com um consultor</router-link>
          </div>
        </div>
      </div>
    </header>

    <div class="container features">
      <div class="grid-3">
        <article class="feature">
          <i class="fa-solid fa-shield-halved icon"></i>
          <h3>Confiança</h3>
          <p>Processos claros e suporte jurídico para uma transação segura.</p>
        </article>
        <article class="feature">
          <i class="fa-solid fa-star icon"></i>
          <h3>Qualidade</h3>
          <p>Fotos profissionais, visitas virtuais e descrição completa dos imóveis.</p>
        </article>
        <article class="feature">
          <i class="fa-solid fa-bolt icon"></i>
          <h3>Agilidade</h3>
          <p>Agendamento online, notificações e respostas rápidas da equipe.</p>
        </article>
      </div>

      <div class="about-explain mt-4">
        <p>
          Na eDomi, unimos tecnologia e experiência humana para facilitar todas as etapas da sua jornada imobiliária.
          Selecionamos imóveis com cuidado, oferecemos informações detalhadas e damos suporte personalizado para que
          suas decisões sejam seguras e bem fundamentadas. Nosso sistema permite agendar visitas, receber notificações
          e acompanhar o processo com total transparência.
        </p>
      </div>
    </div>
  </section>
</template>

<script setup>
// component local data for agents (static placeholders; substitute por dados reais se desejar)
const agents = [
  { id: 1, name: 'Lucas Almeida', role: 'Consultor Sênior', phone: '(11) 91234-5678', photo: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=600&auto=format&fit=crop&ixlib=rb-4.0.3&s=0b1f4c2a4c8b6a4d' },
  { id: 2, name: 'Ana Beatriz', role: 'Corretora', phone: '(11) 99876-5432', photo: 'https://images.unsplash.com/photo-1545996124-1b6f8bff8b33?q=80&w=600&auto=format&fit=crop&ixlib=rb-4.0.3&s=aa9b7d8f0b7c2d9a' },
  { id: 3, name: 'Marcos Vinicius', role: 'Especialista em Investimento', phone: '(11) 93456-7890', photo: 'https://images.unsplash.com/photo-1545996124-1b6f8bff8b33?q=80&w=600&auto=format&fit=crop&ixlib=rb-4.0.3&s=bb2c5f8e9a' },
]
</script>

<style scoped>
.about-page {
  --primary: #1A2E66;
  --secondary: #4ADE80;
  --card-shadow: 0 10px 30px rgba(26,46,102,0.08);
  --card-shadow-hover: 0 18px 40px rgba(26,46,102,0.12);
}

/* HERO */
.hero {
  position: relative;
  overflow: hidden;
  border-radius: 0.5rem;
  margin-bottom: 2rem;
  min-height: 360px;
  display: flex;
  align-items: center;
}
.hero-bg {
  position: absolute;
  inset: 0;
  background-image: linear-gradient(120deg, rgba(26,46,102,0.35), rgba(74,222,128,0.08)), url('https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=1600&auto=format&fit=crop&ixlib=rb-4.0.3&s=8a1f7f9c4a');
  background-size: cover;
  background-position: center;
  filter: saturate(0.95) contrast(1.02);
  transform: scale(1.03);
  z-index: 0;
}
.hero-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(26,46,102,0.25) 0%, rgba(26,46,102,0.45) 100%);
  z-index: 1;
}
.hero-inner {
  position: relative;
  z-index: 2;
  display: grid;
  grid-template-columns: 1fr 420px;
  gap: 2rem;
  align-items: center;
  padding: 3rem 1rem;
}
.hero-copy h1 {
  color: #fff;
  font-size: 2.1rem;
  margin: 0 0 0.6rem 0;
}
.hero-copy .lead {
  color: #e7eefc;
  max-width: 50ch;
  margin-bottom: 1rem;
}
.btn-cta {
  margin-right: 0.5rem;
}
.btn-cta-primary, .btn-cta-primary:visited { background: var(--primary); color: #fff; border: 0; padding: 0.6rem 1rem; border-radius: .45rem; box-shadow: var(--card-shadow); }
.btn-cta-outline { border: 1px solid rgba(255,255,255,0.16); color: #fff; background: transparent; padding: 0.55rem 0.9rem; border-radius: .45rem; }

/* botão "Ver Imóveis" — cor fixa #1A2E66, animação grow */
.btn-view-imoveis {
  background: var(--primary);
  color: #ffffff;
  border: 0;
  padding: 0.6rem 1rem;
  border-radius: 0.45rem;
  font-weight: 700;
  box-shadow: var(--card-shadow);
  transition: transform .18s ease, box-shadow .18s ease, opacity .12s;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  text-decoration: none;
}
.btn-view-imoveis:hover {
  transform: scale(1.06);
  box-shadow: var(--card-shadow-hover);
}
.btn-view-imoveis:active {
  transform: scale(0.99);
}
.btn-view-imoveis:focus {
  outline: 3px solid rgba(74,222,128,0.12);
  outline-offset: 3px;
}

/* ajustar hover do botão "Fale com um consultor" para usar verde #4ADE80 */
.btn-outline-cta {
  border: 1px solid rgba(255,255,255,0.16);
  color: #fff;
  background: transparent;
  padding: 0.55rem 0.9rem;
  border-radius: 0.45rem;
  transition: color .15s ease, border-color .15s ease, background .15s ease, transform .12s ease;
  display: inline-flex;
  align-items: center;
  text-decoration: none;
}
.btn-outline-cta:hover {
  color: var(--secondary);
  border-color: var(--secondary);
  background: rgba(74,222,128,0.06);
  transform: translateY(-3px);
}

/* hero cards */
.hero-cards {
  display: grid;
  gap: 1rem;
  grid-auto-rows: 1fr;
}
.card-brief {
  background: rgba(255,255,255,0.04);
  border-radius: .6rem;
  overflow: hidden;
  display: flex;
  gap: .75rem;
  align-items: center;
  padding: .5rem;
  transition: transform .22s ease, box-shadow .22s ease;
  border: 1px solid rgba(255,255,255,0.04);
  box-shadow: var(--card-shadow);
}
.card-brief img { width: 84px; height: 64px; object-fit: cover; border-radius: 6px; }
.card-brief-body h4 { color: #fff; margin: 0 0 .25rem 0; font-size: 1rem; }
.card-brief-body p { margin: 0; color: var(--muted); font-size: .85rem; }
.card-brief:hover { transform: translateY(-6px); box-shadow: var(--card-shadow-hover); }

/* FEATURES */
.features { margin-top: 4rem; margin-bottom: 1.5rem; }
.grid-3 { display: grid; grid-template-columns: repeat(3,1fr); gap: 1rem; }
.feature { background: #fff; border-radius: .6rem; padding: 1.25rem; text-align: center; box-shadow: var(--card-shadow); }
.feature .icon { color: var(--primary); background: linear-gradient(180deg,#fff 0%, #f8fafc 100%); border-radius: 12px; padding: 12px; font-size: 20px; margin-bottom: .5rem; color: var(--primary); }
.feature h3 { margin: 0 0 .5rem 0; color: var(--primary); }
.feature p { color: var(--muted); margin: 0; }

/* explanatory paragraph styling */
.about-explain { color: #0b2546; background: #fff; padding: 3rem 3.25rem; border-radius: .5rem; box-shadow: var(--card-shadow); }
.about-explain p { margin: 0; color: var(--muted); }

/* STATS STRIP */
.stats-strip { background: linear-gradient(90deg, rgba(26,46,102,0.03), rgba(74,222,128,0.02)); padding: 1rem 0; margin: 2rem 0; border-radius: .5rem; }
.stats-grid { display: grid; grid-template-columns: repeat(4,1fr); gap: 1rem; text-align: center; align-items: center; }
.stat-num { font-weight: 700; color: var(--primary); font-size: 1.4rem; }
.stat-label { color: var(--muted); font-size: .9rem; }

/* TEAM */
.section { padding: 1.25rem 0 2rem 0; }
.section-head h2 { margin: 0 0 .25rem 0; color: var(--primary); }
.section-head .muted { color: var(--muted); margin-bottom: 1rem; }

.team-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 1rem; }
.agent-card { background: #fff; border-radius: .6rem; overflow: hidden; box-shadow: var(--card-shadow); display:flex; gap: .75rem; align-items: center; padding: .8rem; }
.agent-card img { width: 68px; height: 68px; border-radius: 50%; object-fit: cover; }
.agent-body .agent-name { font-weight: 700; color: var(--primary); }
.agent-role, .agent-contact { color: var(--muted); }

/* TESTIMONIALS */
.testi-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 1rem; margin-top: .75rem; }
.testi { background: linear-gradient(180deg,#ffffff 0%, #f8fafc 100%); padding: 1.1rem; border-radius: .6rem; box-shadow: var(--card-shadow); font-style: italic; color: #0b2546; }
.testi cite { display:block; margin-top: .6rem; font-style: normal; color: var(--muted); }

/* CTA FOOTER */
.about-cta { background: linear-gradient(90deg, rgba(26,46,102,0.06), rgba(245,158,11,0.02)); padding: 1.25rem 0; border-radius: .6rem; margin-top: 2rem; }
.cta-inner { display:flex; justify-content:space-between; align-items:center; gap:1rem; }
.btn-cta-primary { background: var(--secondary); color: #07203a; border: none; padding: .6rem 1rem; border-radius: .5rem; font-weight: 700; }
.btn-cta-outline { border: 1px solid var(--secondary); color: var(--secondary); background: transparent; padding: .55rem .9rem; border-radius: .5rem; }

/* responsive */
@media (max-width: 992px) {
  .hero-inner { grid-template-columns: 1fr; padding: 2rem 1rem; }
  .grid-3 { grid-template-columns: 1fr; }
  .stats-grid { grid-template-columns: repeat(2,1fr); }
  .team-grid { grid-template-columns: repeat(2,1fr); }
  .testi-grid { grid-template-columns: 1fr; }
  .cta-inner { flex-direction: column; align-items: flex-start; }
}
</style>
