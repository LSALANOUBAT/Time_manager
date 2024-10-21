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
  name: 'UserLogin', // Updated component name to multi-word
  data() {
    return {
      email: '',
      password: '',
      errorMessage: null,
    };
  },
  methods: {
    async loginUser() {
      // Basic validation to ensure email and password are filled
      if (!this.email || !this.password) {
        this.errorMessage = 'Email and password are required';
        return;
      }

      try {
        const response = await fetch(`${apiUrl}/sign_in`, {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({email: this.email, password: this.password}),
        });

        const data = await response.json();

        if (!response.ok) {
          throw new Error(data.error || 'Login failed');
        }

        // Store the JWT token and user ID
        localStorage.setItem('token', data.token);
        localStorage.setItem('userId', data.user.id);

        // Redirect to the dashboard after successful login
        this.$router.push('/dashboard');
      } catch (error) {
        this.errorMessage = error.message || 'Failed to login. Please check your credentials.';
      }
    },
  },
};
</script>

<style scoped>
.login-component {
  margin-top: 20px;
}

.error-message {
  color: red;
  margin-top: 10px;
}
</style>
