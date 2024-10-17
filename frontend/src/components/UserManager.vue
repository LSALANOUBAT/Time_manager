<template>
  <div class="user-component">
    <h2>User Management</h2>
    <form @submit.prevent="createUser">
      <input v-model="username" placeholder="Username" required />
      <input v-model="email" type="email" placeholder="Email" required />
      <button type="submit">Create User</button>
    </form>
    
    <input v-model="userId" placeholder="User ID" />
    <button @click="getUser">Get User</button>
    <button @click="updateUser">Update User</button>
    <button @click="deleteUser">Delete User</button>

    <div v-if="userData">
      <h3>User Details:</h3>
      <p><strong>Username:</strong> {{ userData.username }}</p>
      <p><strong>Email:</strong> {{ userData.email }}</p>
    </div>

    <div v-if="errorMessage" class="error-message">
      <p>Error: {{ errorMessage }}</p>
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
      userId: '',
      userData: null,
      errorMessage: null,
    };
  },
  methods: {
    async createUser() {
      try {
        const response = await fetch(`${apiUrl}/users`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            user: {
              username: this.username,
              email: this.email,
            },
          }),
        });

        const data = await response.json();
        console.log('User created:', data);
        this.userData = data;
        this.clearFields();
      } catch (error) {
        console.error('Failed to create user:', error);
        this.errorMessage = 'Failed to create user. Please try again.';
      }
    },

    async getUser() {
      try {
        const response = await fetch(`${apiUrl}/${this.userId}`);

        if (!response.ok) {
          throw new Error(`Server error: ${response.status}`);
        }

        const data = await response.json();
        console.log('User data:', data);
        this.userData = data;
      } catch (error) {
        console.error('Failed to fetch user data:', error);
        this.errorMessage = 'Failed to fetch user data. Please check the User ID.';
      }
    },

    async updateUser() {
      try {
        const response = await fetch(`${apiUrl}/${this.userId}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            user: {
              username: this.username,
              email: this.email,
            },
          }),
        });

        const data = await response.json();
        console.log('User updated:', data);
        this.userData = data;
        this.clearFields();
      } catch (error) {
        console.error('Failed to update user:', error);
        this.errorMessage = 'Failed to update user. Please try again.';
      }
    },

    async deleteUser() {
      try {
        const response = await fetch(`${apiUrl}/${this.userId}`, {
          method: 'DELETE',
        });

        if (!response.ok) {
          throw new Error(`Server error: ${response.status}`);
        }

        console.log('User deleted successfully');
        this.userData = null;
        this.clearFields();
      } catch (error) {
        console.error('Failed to delete user:', error);
        this.errorMessage = 'Failed to delete user. Please check the User ID.';
      }
    },

    clearFields() {
      this.username = '';
      this.email = '';
      this.userId = '';
      this.errorMessage = null;
    },
  },
};
</script>