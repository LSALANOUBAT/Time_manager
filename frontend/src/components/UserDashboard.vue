<template>
  <div class="dashboard">
    <!-- Hamburger Menu -->
    <HamburgerMenu />

    <h2 class="dashboard-title">User Management Dashboard</h2>

    <!-- Afficher UserManager seulement si l'utilisateur n'est pas un employé -->
    <user-manager v-if="isAllowedToManageUsers" />

    <!-- Message d'erreur si l'utilisateur n'est pas autorisé -->
    <div v-else>
      <p></p>
    </div>
  </div>
</template>

<script>
import { toastController } from '@ionic/vue';
import UserManager from './UserManager.vue'; // Import the UserManager component
import HamburgerMenu from './HamburgerMenu.vue'; // Import HamburgerMenu component
const apiUrl = process.env.VUE_APP_API_URL;

export default {
  name: 'UserDashboard',
  components: {
    UserManager, // Register UserManager component
    HamburgerMenu, // Register HamburgerMenu component
  },
  data() {
    return {
      user: {},
      isAllowedToManageUsers: false, // Flag to determine if the user can access UserManager
    };
  },
  methods: {
    async fetchUserRole() {
      const token = localStorage.getItem('token');
      const userId = localStorage.getItem('userId'); // Assuming you store the user ID after login

      try {
        // Fetch user information
        const userResponse = await fetch(`${apiUrl}/users/${userId}`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });

        if (!userResponse.ok) {
          throw new Error('Failed to fetch user data');
        }

        const userData = await userResponse.json();
        this.user = userData;

        // Set flag based on user's role
        if (userData.role !== 'employee') {
          this.isAllowedToManageUsers = true;
        } else {
          this.isAllowedToManageUsers = false;
          this.showToast('You do not have permission to access this resource.', 'danger');
        }
      } catch (error) {
        this.showToast('Error fetching user data: ' + error.message, 'danger');
      }
    },

    // Function to show a toast message
    async showToast(message, color) {
      const toast = await toastController.create({
        message,
        duration: 3000,
        color: color || 'primary',
        position: 'top',
      });
      return toast.present();
    },
  },
  mounted() {
    this.fetchUserRole();
  },
};
</script>

<style scoped>
/* Style global pour le dashboard */
.dashboard {
  padding: 20px;
  height: 100vh; /* Full viewport height */
  overflow-y: auto; /* Allow scrolling if content overflows */
  background-color: #f4f4f4;
}

/* Titre principal */
.dashboard-title {
  font-size: 2em;
  color: #333;
  text-align: center;
  margin-bottom: 30px;
}

/* Hamburger menu styling */
.hamburger-menu {
  position: absolute; /* Prevent it from pushing other content */
  top: 20px;
  left: 20px;
  z-index: 1000; /* Ensure it stays on top */
}

/* Responsive layout adjustments */
@media (max-width: 768px) {
  .dashboard {
    padding: 10px; /* Reduce padding on smaller screens */
  }

  h2 {
    font-size: 1.5em; /* Smaller font size for mobile */
  }
}

@media (max-width: 480px) {
  h2 {
    font-size: 1.2em;
  }
}
</style>
