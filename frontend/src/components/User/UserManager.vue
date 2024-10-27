<template>
  <div class="user-manager">
    <h2>User Management</h2>

    <!-- Form to add or edit a user -->
    <form @submit.prevent="submitUser" class="user-form">
      <h3 v-if="editingUser">Edit User</h3>
      <h3 v-else>Add New User</h3>
      <input v-model="formData.username" placeholder="Username" required />
      <input v-model="formData.email" type="email" placeholder="Email" required />
      <input
          v-if="!editingUser"
          v-model="formData.password"
          type="password"
          placeholder="Password"
          required
          minlength="6"
      />

      <!-- Dropdown for role selection -->
      <label for="role">Role:</label>
      <select v-model="formData.role" required>
        <option value="admin">Admin</option>
        <option value="manager">Manager</option>
        <option value="employee">Employee</option>
      </select>

      <!-- Submit button (Add or Update) -->
      <button type="submit" :class="editingUser ? 'button button-update' : 'button button-add'">
        {{ editingUser ? 'Update User' : 'Add User' }}
      </button>
    </form>

    <!-- Display users in a grid -->
    <h3>All Users</h3>
    <GridTable :users="users" @editUser="editUser" @deleteUser="deleteUser" />
  </div>
</template>

<script>
import { toastController } from '@ionic/vue';
import GridTable from './GridTable.vue';

export default {
  name: 'UserManager',
  components: {
    GridTable,
  },
  data() {
    return {
      users: [],
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
    // Fetch all users from the API
    async fetchUsers() {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/users`, {
          headers: { Authorization: `Bearer ${localStorage.getItem('token')}` },
        });

        if (!response.ok) throw new Error('Failed to fetch users');

        this.users = await response.json();
      } catch (error) {
        this.showToast('Error fetching users: ' + error.message, 'danger');
      }
    },

    // Add or update a user
    async submitUser() {
      try {
        let response;
        const userPayload = {
          user: {
            username: this.formData.username,
            email: this.formData.email,
            role: this.formData.role,
          },
        };

        if (this.editingUser) {
          response = await fetch(`${process.env.VUE_APP_API_URL}/users/${this.editingUser.id}`, {
            method: 'PUT',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${localStorage.getItem('token')}`,
            },
            body: JSON.stringify(userPayload),
          });
        } else {
          userPayload.user.password = this.formData.password; // Include password only for new users
          response = await fetch(`${process.env.VUE_APP_API_URL}/users`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${localStorage.getItem('token')}`,
            },
            body: JSON.stringify(userPayload),
          });
        }

        if (!response.ok) throw new Error('Failed to submit user');

        this.showToast(this.editingUser ? 'User updated successfully!' : 'User added successfully!', 'success');
        this.resetForm();
        await this.fetchUsers();
      } catch (error) {
        this.showToast('Error submitting user: ' + error.message, 'danger');
      }
    },

    // Method to reset form and editing state
    resetForm() {
      this.editingUser = null;
      this.formData = { username: '', email: '', password: '', role: 'employee' };
    },

    // Select a user for editing
    editUser(userId) {
      const user = this.users.find((u) => u.id === userId);
      this.editingUser = user;
      this.formData = {
        username: user.username,
        email: user.email,
        role: user.role,
        password: '', // Password is not editable here
      };
    },

    // Delete a user
    async deleteUser(userId) {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/users/${userId}`, {
          method: 'DELETE',
          headers: { Authorization: `Bearer ${localStorage.getItem('token')}` },
        });

        if (!response.ok) throw new Error('Failed to delete user');

        this.showToast('User deleted successfully!', 'success');
        await this.fetchUsers();
      } catch (error) {
        this.showToast('Error deleting user: ' + error.message, 'danger');
      }
    },

    // Show a toast message
    async showToast(message, color) {
      const toast = await toastController.create({
        message,
        duration: 3000,
        color,
        position: 'top',
      });
      await toast.present();
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

/* Base style for all buttons */
.button {
  padding: 8px 16px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-size: 14px;
  color: white;
  transition: background-color 0.3s ease, transform 0.2s ease;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

/* Style on hover */
.button:hover {
  transform: translateY(-2px);
}

/* Add User button */
.button-add {
  background-color: #007bff;
}
.button-add:hover {
  background-color: #0056b3;
}

/* Update User button */
.button-update {
  background-color: #28a745;
}
.button-update:hover {
  background-color: #218838;
}

/* Edit button */
.button-edit {
  background-color: #007bff;
}
.button-edit:hover {
  background-color: #0056b3;
}

/* Delete button */
.button-delete {
  background-color: crimson;
}
.button-delete:hover {
  background-color: darkred;
}

/* Disabled button state */
.button:disabled {
  background-color: #ccc;
  color: #666;
  cursor: not-allowed;
  box-shadow: none;
}
</style>
