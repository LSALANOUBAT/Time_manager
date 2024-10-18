<template>
  <div class="user-component">
    <h2>User Management</h2>

    <!-- Formulaire pour créer un nouvel utilisateur -->
    <form @submit.prevent="createUser">
      <input v-model="username" placeholder="Username" required />
      <input v-model="email" type="email" placeholder="Email" required />
      <button type="submit">Create User</button>
    </form>

    <input v-model="userId" placeholder="User ID" />
    <button @click="getUser">Get User</button>
    <button @click="updateUser">Update User</button>
    <button @click="deleteUser">Delete User</button>

    <!-- Affichage des détails de l'utilisateur -->
    <div v-if="userData">
      <h3>User Details:</h3>
      <p><strong>Username:</strong> {{ userData.username }}</p>
      <p><strong>Email:</strong> {{ userData.email }}</p>
    </div>

    <!-- Gestion des erreurs -->
    <div v-if="errorMessage" class="error-message">
      <p>Error: {{ errorMessage }}</p>
    </div>

    <!-- Tableau de tous les utilisateurs -->
    <h3>Liste des utilisateurs :</h3>
    <table v-if="users.length" class="user-table">
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
          <button @click="selectUser(user)">Sélectionner</button>
          <button @click="deleteUser(user.id)">Supprimer</button>
        </td>
      </tr>
      </tbody>
    </table>
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
      users: [],
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
        this.users.push(data); // Ajouter le nouvel utilisateur au tableau
        this.clearFields();
      } catch (error) {
        console.error('Failed to create user:', error);
        this.errorMessage = 'Failed to create user. Please try again.';
      }
    },

    async getUser() {
      try {
        const response = await fetch(`${apiUrl}/users/${this.userId}`);

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
        const response = await fetch(`${apiUrl}/users/${this.userId}`, {
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
        const index = this.users.findIndex(user => user.id === data.id);
        if (index !== -1) {
          this.$set(this.users, index, data); // Met à jour l'utilisateur dans le tableau
        }
        this.clearFields();
      } catch (error) {
        console.error('Failed to update user:', error);
        this.errorMessage = 'Failed to update user. Please try again.';
      }
    },

    async deleteUser(id) {
      try {
        const response = await fetch(`${apiUrl}/users/${id}`, {
          method: 'DELETE',
        });

        if (!response.ok) {
          throw new Error(`Server error: ${response.status}`);
        }

        console.log('User deleted successfully');
        this.users = this.users.filter(user => user.id !== id); // Retirer l'utilisateur du tableau
        this.clearFields();
      } catch (error) {
        console.error('Failed to delete user:', error);
        this.errorMessage = 'Failed to delete user. Please check the User ID.';
      }
    },

    selectUser(user) {
      this.userId = user.id;
      this.username = user.username;
      this.email = user.email;
    },

    async fetchUsers() {
      try {
        const response = await fetch(`${apiUrl}/users`);
        const data = await response.json();
        this.users = data;
      } catch (error) {
        console.error('Failed to fetch users:', error);
        this.errorMessage = 'Failed to load users.';
      }
    },

    clearFields() {
      this.username = '';
      this.email = '';
      this.userId = '';
      this.userData = null;
      this.errorMessage = null;
    },
  },
  mounted() {
    this.fetchUsers(); // Charger les utilisateurs au montage du composant
  },
};
</script>

<style>
.user-component {
  margin-top: 20px;
}

.user-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 20px;
}

.user-table th, .user-table td {
  border: 1px solid #ccc;
  padding: 10px;
}

.user-table th {
  background-color: #f4f4f4;
}

button {
  margin-left: 10px;
}
</style>
