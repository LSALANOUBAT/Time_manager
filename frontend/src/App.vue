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
  mounted() {
    // Configuration de la connexion WebSocket
    const wsUrl = process.env.VUE_APP_WS_URL || 'ws://localhost:8080/ws';
    this.socket = new WebSocket(wsUrl);

    // Gestion des événements WebSocket
    this.socket.onopen = function (event) {
      console.log('WebSocket is open now.');
    };

    this.socket.onmessage = function (event) {
      console.log('WebSocket message received:', event.data);
    };

    this.socket.onclose = function (event) {
      console.log('WebSocket is closed now.');
    };

    this.socket.onerror = function (error) {
      console.error('WebSocket error observed:', error);
    };
  },
  beforeDestroy() {
    // Fermer la connexion WebSocket lorsque le composant est détruit
    if (this.socket) {
      this.socket.close();
    }
  },
};
</script>

<style>
/* Style global pour l'application */
</style>
