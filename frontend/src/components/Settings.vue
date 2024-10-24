<template>
    <div class="settings-page">
      <h2>User Management</h2>
  
      <!-- Form to add new users -->
      <form @submit.prevent="addUser" class="user-form">
        <h3>Add New User</h3>
        <input v-model="newUser.username" placeholder="Username" required />
        <input v-model="newUser.email" type="email" placeholder="Email" required />
        <input v-model="newUser.password" type="password" placeholder="Password" required minlength="6" />
        <button type="submit">Add User</button>
      </form>
  
      <!-- Display users in a table -->
      <table class="user-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Username</th>
            <th>Email</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="user in users" :key="user.id">
            <td>{{ user.id }}</td>
            <td>{{ user.username }}</td>
            <td>{{ user.email }}</td>
            <td>
              <button @click="editUser(user)">Edit</button>
              <button @click="deleteUser(user.id)">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
  
      <!-- Edit user form -->
      <div v-if="editingUser" class="edit-user-form">
        <h3>Edit User</h3>
        <form @submit.prevent="updateUser">
          <input v-model="editingUser.username" placeholder="Username" required />
          <input v-model="editingUser.email" type="email" placeholder="Email" required />
          <button type="submit">Update User</button>
        </form>
      </div>
  
      <div v-if="errorMessage" class="error-message">
        <p>{{ errorMessage }}</p>
      </div>
    </div>
  </template>
  
  <script>
  const apiUrl = process.env.VUE_APP_API_URL;
  
  export default {
    name: 'UserSettings',
    data() {
      return {
        users: [], // List of users
        newUser: {
          username: '',
          email: '',
          password: '',
        }, // New user data
        editingUser: null, // Currently editing user
        errorMessage: null, // Error message
      };
    },
    methods: {
      // Fetch all users (admin/manager only)
      async fetchUsers() {
        try {
          const response = await fetch(`${apiUrl}/users`, {
            headers: {
              Authorization: `Bearer ${localStorage.getItem('token')}`,
            },
          });
          if (!response.ok) throw new Error('Failed to fetch users');
          this.users = await response.json();
        } catch (error) {
          this.errorMessage = error.message;
        }
      },
  
      // Add a new user (admin/manager only)
      async addUser() {
        try {
          const response = await fetch(`${apiUrl}/users`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${localStorage.getItem('token')}`,
            },
            body: JSON.stringify(this.newUser),
          });
  
          if (!response.ok) throw new Error('Failed to add user');
          const addedUser = await response.json();
          this.users.push(addedUser); // Add new user to the list
          this.newUser = { username: '', email: '', password: '' }; // Reset the form
        } catch (error) {
          this.errorMessage = error.message;
        }
      },
  
      // Edit an existing user (admin/manager only)
      editUser(user) {
        this.editingUser = { ...user }; // Create a copy of the user object for editing
      },
  
      // Update an existing user (admin/manager only)
      async updateUser() {
        try {
          const response = await fetch(`${apiUrl}/users/${this.editingUser.id}`, {
            method: 'PUT',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${localStorage.getItem('token')}`,
            },
            body: JSON.stringify(this.editingUser),
          });
  
          if (!response.ok) throw new Error('Failed to update user');
          const updatedUser = await response.json();
          const index = this.users.findIndex((user) => user.id === updatedUser.id);
          if (index !== -1) this.users.splice(index, 1, updatedUser); // Update the user in the list
          this.editingUser = null; // Close the edit form
        } catch (error) {
          this.errorMessage = error.message;
        }
      },
  
      // Delete a user (admin only)
      async deleteUser(userId) {
        try {
          const response = await fetch(`${apiUrl}/users/${userId}`, {
            method: 'DELETE',
            headers: {
              Authorization: `Bearer ${localStorage.getItem('token')}`,
            },
          });
  
          if (!response.ok) throw new Error('Failed to delete user');
          this.users = this.users.filter((user) => user.id !== userId); // Remove user from the list
        } catch (error) {
          this.errorMessage = error.message;
        }
      },
    },
    mounted() {
      this.fetchUsers(); // Fetch users when component is mounted
    },
  };
  </script>
  
  <style scoped>
  .settings-page {
    padding: 20px;
  }
  
  .user-form, .edit-user-form {
    background-color: white;
    padding: 20px;
    border-radius: 12px;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    margin-bottom: 30px;
  }
  
  .user-table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 30px;
  }
  
  .user-table th, .user-table td {
    border: 1px solid #ddd;
    padding: 8px;
  }
  
  .user-table th {
    background-color: #f2f2f2;
  }
  
  button {
    background-color: white;
    color: black;
    border-radius: 10em;
    font-size: 15px;
    padding: 0.5em 1em;
    cursor: pointer;
    transition: all 0.3s ease-in-out;
    border: 1px solid black;
    box-shadow: 0 0 0 0 black;
  }
  
  button:hover {
    transform: translateY(-2px) translateX(-1px);
    box-shadow: 2px 4px 0 0 black;
  }
  
  button:active {
    transform: translateY(2px) translateX(1px);
    box-shadow: 0 0 0 0 black;
  }
  
  .error-message {
    color: red;
  }
  </style>
  