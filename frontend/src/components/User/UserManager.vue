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
    <h3>Recently Created or Modified Users</h3>
    <GridTable :users="recentUsers" @editUser="editUser" @deleteUser="deleteUser" />

    <!-- Histogram showing users created per day -->
    <Histogram :users="users" />
  </div>
</template>

<script>
import { toastController } from '@ionic/vue';
import Histogram from '../chart/Histogram.vue';
import GridTable from './GridTable.vue'; // Import GridTable component

export default {
  name: 'UserManager',
  components: {
    Histogram, // Register the Histogram component
    GridTable, // Register the GridTable component
  },
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

        if (this.editingUser) {
          if (!this.editingUser.id) {
            this.showToast('No user selected for editing', 'danger');
            return; // Prevents request if no user is selected
          }

          // Update user without password
          const userUpdate = {
            user: {
              username: this.formData.username,
              email: this.formData.email,
              role: this.formData.role,
            },
          };

          response = await fetch(`${process.env.VUE_APP_API_URL}/users/${this.editingUser.id}`, {
            method: 'PUT',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${localStorage.getItem('token')}`,
            },
            body: JSON.stringify(userUpdate),
          });
        } else {
          // Create new user, include password
          const userPayload = {
            user: {
              username: this.formData.username,
              email: this.formData.email,
              password: this.formData.password, // Include password for creation
              role: this.formData.role,
            },
          };

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
        this.fetchUsers(); // Refresh users after creation or update
      } catch (error) {
        this.showToast('Error submitting user: ' + error.message, 'danger');
      }
    },

    // Method to select a user for editing
    editUser(userId) {
      const user = this.users.find((u) => u.id === userId);
      this.editingUser = user; // Set the editing user
      // Populate the form with the selected user's data (except password)
      this.formData = {
        username: user.username,
        email: user.email,
        role: user.role,
        password: '', // Leave password empty, since it is not editable during update
      };
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
        this.fetchUsers(); // Refresh users after deletion
      } catch (error) {
        this.showToast('Error deleting user: ' + error.message, 'danger');
      }
    },

    // Show a toast message
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