<template>
  <div id="app">
    <header v-if="isAuthenticated">
      <h1>Time Manager Application</h1>
      <button @click="logout">Logout</button>
    </header>
    <main>
      <router-view /> <!-- Affiche le contenu des routes -->
    </main>
  </div>
</template>

<script>
import { isAuthenticated } from './router/auth';

export default {
  name: 'App',
  computed: {
    isAuthenticated() {
      return isAuthenticated(); // Vérifie si l'utilisateur est authentifié
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
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  text-align: center;
  color: #2c3e50;
  margin-top: 20px;
}

header {
  background-color: #42b983;
  padding: 10px;
  color: white;
}

main {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
  margin-top: 20px;
}
</style>
