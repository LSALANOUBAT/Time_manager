<template>
  <div class="register-component">
    <form class="form" @submit.prevent="registerUser">
      <p class="heading">Register</p>
      <input v-model="username" class="input" placeholder="Username" required />
      <input v-model="email" class="input" type="email" placeholder="Email" required />
      <input
        v-model="password"
        class="input"
        type="password"
        placeholder="Password"
        required
        minlength="6"
      />
      <button type="submit" class="btn">Register</button>
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

.error-message {
  color: red;
  margin-top: 10px;
}
</style>
