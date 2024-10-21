<template>
  <div class="register-component">
    <h2>Register</h2>
    <form @submit.prevent="registerUser">
      <input v-model="username" placeholder="Username" required />
      <input v-model="email" type="email" placeholder="Email" required />
      <input v-model="password" type="password" placeholder="Password" required minlength="6"/>
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
      try {
        const response = await fetch(`${apiUrl}/users`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            user: {
              username: this.username,
              email: this.email,
              password: this.password, // Envoie le mot de passe pour être haché côté backend
            },
          }),
        });

        if (!response.ok) {
          const errorData = await response.json(); // Récupérer les erreurs du backend
          throw new Error(errorData.errors || 'Registration failed');
        }

        const data = await response.json();
        localStorage.setItem('token', data.token); // Stocker le JWT après la création de l'utilisateur
        this.$router.push('/'); // Rediriger l'utilisateur après enregistrement
      } catch (error) {
        this.errorMessage = error.message || 'Failed to register. Please try again.';
      }
    },
  },
};
</script>

<style>
.register-component {
  margin-top: 20px;
}

.error-message {
  color: red;
  margin-top: 10px;
}
</style>
