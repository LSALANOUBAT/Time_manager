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
  </div>
</template>

<script>
import { toastController } from '@ionic/vue'; // Import Ionic toast controller
const apiUrl = process.env.VUE_APP_API_URL;

export default {
  name: 'UserLogin',
  data() {
    return {
      email: '',
      password: '',
    };
  },
  methods: {
    async loginUser() {
      // Basic validation to ensure email and password are filled
      if (!this.email || !this.password) {
        this.presentToast('Email and password are required');
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
        this.presentToast(error.message || 'Failed to login. Please check your credentials.');
      }
    },
    async presentToast(message) {
      const toast = await toastController.create({
        message: message,
        duration: 2000, // Toast will disappear after 2 seconds
        position: 'top', // Show toast at the top of the screen
        color: 'danger', // Set toast color to red for error
      });
      return toast.present();
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
  width: 350px;
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
  font-size: 1.5em;
}

.input {
  border-radius: 5px;
  border: 1px solid whitesmoke;
  background-color: whitesmoke;
  outline: none;
  padding: 1em;
  transition: .4s ease-in-out;
  font-size: 1.1em;
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
  font-size: 1.1em;
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

.register-link {
  margin-top: 15px;
  text-align: center;
}

button {
  background-color: transparent;
  border: none;
  color: blue;
  cursor: pointer;
  text-decoration: underline;
  font-size: 1.1em;
}

button:hover {
  color: darkblue;
}
</style>
