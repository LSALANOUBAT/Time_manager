<template>
  <div id="app">
    <header v-if="isAuthenticated">
      <h1>Time Manager Application</h1>
      <button @click="logout">Logout</button>
    </header>
    <router-view /> <!-- Affiche le contenu des routes ici -->
  </div>
</template>

<script>
import { isAuthenticated } from './router/auth'; // Vérifie si l'utilisateur est authentifié

export default {
  name: 'App',
  computed: {
    isAuthenticated() {
      return isAuthenticated(); // Vérifie si l'utilisateur est connecté
    },
  },
  methods: {
    logout() {
      localStorage.removeItem('token'); // Supprime le token JWT
      this.$router.push('/login'); // Redirige vers la page de login après déconnexion
    },
  },
};
</script>

<style>
/* Style global pour l'application */
</style>
