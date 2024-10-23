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
  data() {
    return {
      isAuth: isAuthenticated(), // Initialise l'état de l'authentification
    };
  },
  watch: {
    // Utilise un watcher pour détecter les changements de route
    '$route'() {
      this.updateAuthState();
    },
  },
  methods: {
    logout() {
      localStorage.removeItem('token'); // Supprime le token JWT
      this.$router.push('/login'); // Redirige vers la page de login après déconnexion
      this.updateAuthState(); // Met à jour l'état de l'authentification
    },
    updateAuthState() {
      this.isAuth = isAuthenticated(); // Mets à jour la valeur de isAuth en fonction de l'état de l'authentification
    },
  },
  computed: {
    isAuthenticated() {
      return this.isAuth; // Utilise la propriété isAuth
    },
  },
  created() {
    this.updateAuthState(); // Assure-toi que l'état est mis à jour au chargement du composant
  },
};
</script>

<style>
/* Style global pour l'application */
</style>
