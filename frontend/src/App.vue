<template>
  <div id="app">
    <header v-if="isAuthenticated">
      <h1>Time Manager Application</h1>
      <button @click="logout">Logout</button>
    </header>
    <router-view /> <!-- Displays the content of routes here -->
  </div>
</template>

<script>
import { isAuthenticated } from './router/auth'; // Checks if the user is authenticated

export default {
  name: 'App',
  computed: {
    isAuthenticated() {
      return isAuthenticated(); // Returns true if the user is authenticated
    },
  },
  methods: {
    logout() {
      localStorage.removeItem('token'); // Removes JWT token from local storage
      this.$router.push('/login'); // Redirects to the login page after logout
    },
  },
  mounted() {
    // WebSocket connection configuration
    const wsUrl = process.env.VUE_APP_WS_URL || 'ws://localhost:8080/ws';
    this.socket = new WebSocket(wsUrl);

    // WebSocket event handlers
    this.socket.onopen = function () {
      console.log('WebSocket is open now.');
    };

    this.socket.onmessage = function (event) {
      console.log('WebSocket message received:', event.data);
    };

    this.socket.onclose = function () {
      console.log('WebSocket is closed now.');
    };

    this.socket.onerror = function (error) {
      console.error('WebSocket error observed:', error);
    };
  },
  beforeUnmount() { // Changed from beforeDestroy to beforeUnmount
    // Close the WebSocket connection when the component is unmounted
    if (this.socket) {
      this.socket.close();
    }
  },
};
</script>

<style>
/* Global styles for the application */
</style>
