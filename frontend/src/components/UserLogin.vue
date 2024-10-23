<template>
  <div class="login-component">
    <form class="form" @submit.prevent="loginUser">
      <p class="heading">Login</p>
      <input v-model="email" class="input" type="email" placeholder="Email" required />
      <input v-model="password" class="input" type="password" placeholder="Password" required />
      <button type="submit" class="btn">Login</button>

      <!-- Button to navigate to the register page -->
      <div class="register-link">
        <p>Don't have an account?
          <button @click="goToRegister">Register here</button>
        </p>
      </div>
    </form>

    <div v-if="errorMessage" class="error-message">
      <p>{{ errorMessage }}</p>
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
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  background-color: #f4f4f4;
}

.form {
  display: flex;
  flex-direction: column;
  gap: 15px;
  background-color: white;
  padding: 3em;
  border-radius: 25px;
  transition: .4s ease-in-out;
  box-shadow: rgba(0, 0, 0, 0.4) 1px 2px 2px;
  width: 350px; /* Augmente la largeur du formulaire */
}

.form:hover {
  transform: translateX(-0.5em) translateY(-0.5em);
  border: 1px solid #171717;
  box-shadow: 10px 10px 0px #666666;
}

.heading {
  color: black;
  padding-bottom: 2em;
  text-align: center;
  font-weight: bold;
  font-size: 1.5em; /* Augmente la taille du texte */
}

.input {
  border-radius: 5px;
  border: 1px solid whitesmoke;
  background-color: whitesmoke;
  outline: none;
  padding: 1em;
  transition: .4s ease-in-out;
  font-size: 1.1em; /* Augmente la taille de la police des champs de saisie */
}

.input:hover {
  box-shadow: 6px 6px 0px #969696,
             -3px -3px 10px #ffffff;
}

.input:focus {
  background: #ffffff;
  box-shadow: inset 2px 5px 10px rgba(0,0,0,0.3);
}

.form .btn {
  margin-top: 2em;
  align-self: center;
  padding: 0.7em;
  padding-left: 1em;
  padding-right: 1em;
  border-radius: 10px;
  border: none;
  color: black;
  transition: .4s ease-in-out;
  box-shadow: rgba(0, 0, 0, 0.4) 1px 1px 1px;
  background-color: #f4f4f4;
  font-size: 1.1em; /* Augmente la taille de la police du bouton */
}

.form .btn:hover {
  box-shadow: 6px 6px 0px #969696,
             -3px -3px 10px #ffffff;
  transform: translateX(-0.5em) translateY(-0.5em);
}

.form .btn:active {
  transition: .2s;
  transform: translateX(0em) translateY(0em);
  box-shadow: none;
}

.error-message {
  color: red;
  margin-top: 10px;
}

.register-link {
  margin-top: 15px;
  text-align: center; /* Centre le texte et le bouton */
}

button {
  background-color: transparent;
  border: none;
  color: blue;
  cursor: pointer;
  text-decoration: underline;
  font-size: 1.1em; /* Augmente la taille de la police du lien */
}

button:hover {
  color: darkblue;
}
</style>
