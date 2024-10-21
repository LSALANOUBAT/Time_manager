<template>
  <div class="login-component">
    <h2>Login</h2>
    <form @submit.prevent="loginUser">
      <input v-model="email" type="email" placeholder="Email" required />
      <input v-model="password" type="password" placeholder="Password" required />
      <button type="submit">Login</button>
    </form>

    <div v-if="errorMessage" class="error-message">
      <p>{{ errorMessage }}</p>
    </div>
  </div>
</template>

<script>
const apiUrl = process.env.VUE_APP_API_URL;

export default {
  data() {
    return {
      email: '',
      password: '',
      errorMessage: null,
    };
  },
  methods: {
    async loginUser() {
      try {
        const response = await fetch(`${apiUrl}/sign_in`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email: this.email, password: this.password }),
        });

        if (!response.ok) {
          throw new Error('Login failed');
        }

        const data = await response.json();
        localStorage.setItem('token', data.token); // Stocker le JWT dans le localStorage
        this.$router.push('/'); // Rediriger vers la page principale
      } catch (error) {
        this.errorMessage = 'Failed to login. Please check your credentials.';
      }
    },
  },
};
</script>

<style>
.login-component {
  margin-top: 20px;
}
</style>
