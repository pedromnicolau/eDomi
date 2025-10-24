<template>
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container-fluid">
      <router-link class="navbar-brand" to="/admin">eDomi — Admin</router-link>

      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#adminNav" aria-controls="adminNav" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="adminNav">
        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
          <li class="nav-item"><router-link class="nav-link" to="/admin/kanban">Kanban</router-link></li>

          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" id="cadastrosDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
              Cadastros
            </a>
            <ul class="dropdown-menu" aria-labelledby="cadastrosDropdown">
              <li><router-link class="dropdown-item" to="/admin/cadastros/usuarios">Usuários</router-link></li>
              <li><router-link class="dropdown-item" to="/admin/cadastros/imoveis">Imóveis</router-link></li>
              <li><router-link class="dropdown-item" to="/admin/cadastros/comissoes">Comissões</router-link></li>
              <li><router-link class="dropdown-item" to="/admin/cadastros/vendas">Vendas</router-link></li>
              <li><router-link class="dropdown-item" to="/admin/cadastros/visitas">Visitas</router-link></li>
            </ul>
          </li>

          <li class="nav-item"><router-link class="nav-link" to="/admin/relatorios">Relatórios</router-link></li>
        </ul>

        <ul class="navbar-nav ms-auto">
          <li class="nav-item"><router-link class="nav-link" to="/">Voltar ao site</router-link></li>
        </ul>
      </div>
    </div>
  </nav>
</template>

<script setup>
// ...pode adicionar reatividade/estado se necessário...
</script>

<style scoped>
.navbar-brand { font-weight: 600; }
</style>
