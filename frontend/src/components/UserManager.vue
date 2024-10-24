<template>
  <div class="user-manager">
    <h2>User Management</h2>

    <!-- Form to add or edit a user -->
    <form @submit.prevent="submitUser" class="user-form">
      <h3 v-if="editingUser">Edit User</h3>
      <h3 v-else>Add New User</h3>
      <input v-model="formData.username" placeholder="Username" required />
      <input v-model="formData.email" type="email" placeholder="Email" required />
      <input v-if="!editingUser" v-model="formData.password" type="password" placeholder="Password" required minlength="6" />

      <!-- Dropdown for role selection -->
      <label for="role">Role:</label>
      <select v-model="formData.role" required>
        <option value="admin">Admin</option>
        <option value="manager">Manager</option>
        <option value="employee">Employee</option>
      </select>

      <button type="submit">{{ editingUser ? 'Update User' : 'Add User' }}</button>
    </form>

    <!-- Display users in a table -->
    <h3>Recently Created or Modified Users</h3>
    <table class="user-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Username</th>
          <th>Email</th>
          <th>Role</th>
          <th>Last Modified</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="user in recentUsers" :key="user.id">
          <td>{{ user.id }}</td>
          <td>{{ user.username }}</td>
          <td>{{ user.email }}</td>
          <td>{{ user.role }}</td>
          <td>{{ formatDate(user.updated_at || user.created_at) }}</td>
          <td>
            <button @click="editUser(user)">Edit</button>
            <button @click="deleteUser(user.id)">Delete</button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { toastController } from '@ionic/vue';

export default {
  name: 'UserManager',
  data() {
    return {
      users: [],
      recentUsers: [],
      formData: {
        username: '',
        email: '',
        password: '',
        role: 'employee',
      },
      editingUser: null,
    };
  },
  methods: {
    // Fetch all users
    async fetchUsers() {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/users`, {
          headers: { Authorization: `Bearer ${localStorage.getItem('token')}` },
        });

        if (!response.ok) {
          throw new Error('Failed to fetch users');
        }

        this.users = await response.json();
        this.updateRecentUsers();
      } catch (error) {
        this.showToast('Error fetching users: ' + error.message, 'danger');
      }
    },

    // Filter and display only the 5 most recently created or updated users
    updateRecentUsers() {
      this.recentUsers = this.users
        .sort((a, b) => new Date(b.updated_at || b.created_at) - new Date(a.updated_at || a.created_at))
        .slice(0, 5);
    },

    // Add or update a user
    async submitUser() {
      try {
        let response;
        const userPayload = {
          user: {
            username: this.formData.username,
            email: this.formData.email,
            password: this.formData.password,
            role: this.formData.role,
          },
        };

        if (this.editingUser) {
          // Update user
          response = await fetch(`${process.env.VUE_APP_API_URL}/users/${this.editingUser.id}`, {
            method: 'PUT',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${localStorage.getItem('token')}`,
            },
            body: JSON.stringify(userPayload),
          });
        } else {
          // Create new user
          response = await fetch(`${process.env.VUE_APP_API_URL}/users`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${localStorage.getItem('token')}`,
            },
            body: JSON.stringify(userPayload),
          });
        }

        if (!response.ok) {
          throw new Error('Failed to submit user');
        }

        const user = await response.json();
        if (this.editingUser) {
          const index = this.users.findIndex((u) => u.id === user.id);
          if (index !== -1) this.users.splice(index, 1, user);
          this.showToast('User updated successfully!', 'success');
        } else {
          this.users.push(user);
          this.showToast('User added successfully!', 'success');
        }

        this.editingUser = null;
        this.formData = { username: '', email: '', password: '', role: 'employee' };
        this.updateRecentUsers();
      } catch (error) {
        this.showToast('Error submitting user: ' + error.message, 'danger');
      }
    },

    // Edit an existing user
    editUser(user) {
      this.editingUser = user;
      this.formData = { ...user, password: '' };
    },

    // Delete a user
    async deleteUser(userId) {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/users/${userId}`, {
          method: 'DELETE',
          headers: { Authorization: `Bearer ${localStorage.getItem('token')}` },
        });

        if (!response.ok) {
          throw new Error('Failed to delete user');
        }

        this.users = this.users.filter((user) => user.id !== userId);
        this.showToast('User deleted successfully!', 'success');
        this.updateRecentUsers();
      } catch (error) {
        this.showToast('Error deleting user: ' + error.message, 'danger');
      }
    },

    // Affiche un toast
    async showToast(message, color) {
      const toast = await toastController.create({
        message,
        duration: 3000,
        color: color || 'primary',
        position: 'top',
      });
      return toast.present();
    },

    // Format date for display
    formatDate(dateStr) {
      const date = new Date(dateStr);
      return date.toLocaleString();
    },
  },
  mounted() {
    this.fetchUsers();
  },
};
</script>

<style scoped>
.user-manager {
  padding: 20px;
}

.user-form {
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

.user-table th,
.user-table td {
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
</style>
