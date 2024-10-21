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

    <!-- Button to navigate to the register page -->
    <div class="register-link">
      <p>Don't have an account?
        <button @click="goToRegister">Register here</button>
      </p>
    </div>
  </div>
</template>

<script>
const apiUrl = process.env.VUE_APP_API_URL;

export default {
  name: 'UserLogin', // Updated component name
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
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email: this.email, password: this.password }),
        });

        const data = await response.json();

        if (!response.ok) {
          throw new Error(data.error || 'Login failed');
        }

        // Store the JWT token and user ID
        localStorage.setItem('token', data.token);
        localStorage.setItem('userId', data.user_id); // Store user_id from the response

        // Redirect to the dashboard after successful login
        this.$router.push('/dashboard');
      } catch (error) {
        this.errorMessage = error.message || 'Failed to login. Please check your credentials.';
      }
    },
    goToRegister() {
      this.$router.push('/register'); // Redirect to the register page
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

.register-link {
  margin-top: 15px;
}

button {
  background-color: transparent;
  border: none;
  color: blue;
  cursor: pointer;
  text-decoration: underline;
}

button:hover {
  color: darkblue;
}
</style>
