<template>
  <div class="register-component">
    <h2>Register</h2>
    <form @submit.prevent="registerUser">
      <input v-model="username" placeholder="Username" required />
      <input v-model="email" type="email" placeholder="Email" required />
      <input
          v-model="password"
          type="password"
          placeholder="Password"
          required
          minlength="6"
      />
      <button type="submit">Register</button>
    </form>

    <div v-if="errorMessage" class="error-message">
      <p>{{ errorMessage }}</p>
    </div>
  </div>
</template>

<script>
const apiUrl = process.env.VUE_APP_API_URL;

export default {
  name: 'UserRegister', // Updated component name
  data() {
    return {
      username: '',
      email: '',
      password: '',
      errorMessage: null,
    };
  },
  methods: {
    async registerUser() {
      if (!this.username || !this.email || !this.password) {
        this.errorMessage = 'All fields are required.';
        return;
      }

      try {
        const response = await fetch(`${apiUrl}/users`, {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({
            user: {
              username: this.username,
              email: this.email,
              password: this.password,
            },
          }),
        });

        const data = await response.json();

        if (!response.ok) {
          const errorMessage =
              data.errors && data.errors.message
                  ? data.errors.message
                  : 'Registration failed';
          throw new Error(errorMessage);
        }

        // Store the JWT token and user ID
        localStorage.setItem('token', data.token);
        localStorage.setItem('userId', data.user.id);

        // Redirect to the dashboard after successful registration
        this.$router.push('/dashboard');
      } catch (error) {
        this.errorMessage = error.message || 'Failed to register. Please try again.';
      }
    },
  },
};
</script>

<style scoped>
.register-component {
  margin-top: 20px;
}

.error-message {
  color: red;
  margin-top: 10px;
}
</style>
