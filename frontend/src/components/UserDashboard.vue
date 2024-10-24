<!-- src/components/Dashboard.vue -->
<template>
  <div class="dashboard">
    <!-- Hamburger Menu -->
    <HamburgerMenu />

    <h2 class="dashboard-title">User Management Dashboard</h2>

    <!-- Afficher UserManager seulement si l'utilisateur n'est pas un employé -->
    <user-manager v-if="isAllowedToManageUsers" />

    <!-- Section Clock In / Clock Out pour les employés -->
    <div v-else class="clock-section">
      <h3>Manage Your Working Time</h3>
      <div class="clock-buttons">
        <ClockIn v-if="!hasActiveSession" @clock-in="refreshWorkingTimes" />
        <ClockOut v-if="hasActiveSession" @clock-out="refreshWorkingTimes" />
      </div>
    </div>

    <!-- Message d'erreur si l'utilisateur n'est pas autorisé -->
    <div v-if="isAllowedToManageUsers && errorMessage">
      <p class="error">{{ errorMessage }}</p>
    </div>

    <!-- Clocks Section -->
    <section>
      <h3>Your Clocks</h3>
      <ul>
        <li v-for="clock in clocks" :key="clock.id">
          <strong>Status:</strong> {{ clock.status ? 'In' : 'Out' }} |
          <strong>Time:</strong> {{ formatDate(clock.time) }}
        </li>
      </ul>
    </section>

    <!-- Clock Manager Component -->
    <clock-manager :user-id="user.id"></clock-manager>

    <!-- Working Times Section -->
    <section>
      <h3>Your Working Times</h3>
      <ul>
        <li v-for="wt in workingTimes" :key="wt.id">
          <strong>Start:</strong> {{ formatDate(wt.start) }} |
          <strong>End:</strong> {{ formatDate(wt.end) }}
        </li>
      </ul>
    </section>

    <!-- Working Time Management Component -->
    <working-time :user-id="user.id"></working-time> <!-- Include WorkingTime component -->

    <!-- Chart Manager Section -->
    <chart-manager v-if="user.id" :selected-user-id="user.id"></chart-manager>

    <!-- Calendar Manager Section -->
    <calendar-manager v-if="user.id" :selected-user-id="user.id"></calendar-manager>
  </div>
</template>

<script>
import { toastController } from '@ionic/vue';
import UserManager from './UserManager.vue'; // Import the UserManager component
import HamburgerMenu from './HamburgerMenu.vue'; // Import HamburgerMenu component
import ClockIn from './ClockIn.vue'; // Import ClockIn component
import ClockOut from './ClockOut.vue'; // Import ClockOut component

const apiUrl = process.env.VUE_APP_API_URL;

export default {
  name: 'UserDashboard',
  components: {
    UserManager, // Register UserManager component
    HamburgerMenu, // Register HamburgerMenu component
    ClockIn, // Register ClockIn component
    ClockOut, // Register ClockOut component
  },
  data() {
    return {
      user: {},
      isAllowedToManageUsers: false, // Flag to determine if the user can access UserManager
      clocks: [],
      workingTimes: [],
      errorMessage: '',
      hasActiveSession: false, // Flag to determine if user has an active clock in
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
          this.showToast('You do not have permission to access the User Manager.', 'danger');
        }

        // Fetch working times to determine active session
        await this.fetchWorkingTimes();
      } catch (error) {
        this.showToast('Error fetching user data: ' + error.message, 'danger');
      }
    },

    async fetchWorkingTimes() {
      const token = localStorage.getItem('token');
      const userId = localStorage.getItem('userId');

      try {
        const response = await fetch(`${apiUrl}/workingtime/${userId}`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });

        if (!response.ok) {
          throw new Error('Failed to fetch working times');
        }

        const data = await response.json();
        this.workingTimes = data;

        // Vérifier s'il y a une session active (sans end)
        this.hasActiveSession = data.some(wt => !wt.end);
      } catch (error) {
        this.showToast('Error fetching working times: ' + error.message, 'danger');
      }
    },

    refreshWorkingTimes() {
      this.fetchWorkingTimes();
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

    formatDate(dateStr) {
      const date = new Date(dateStr);
      return date.toLocaleString();
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

/* Section Clock In / Clock Out */
.clock-section {
  margin-bottom: 30px;
  text-align: center;
}

.clock-buttons {
  display: flex;
  justify-content: center;
  gap: 20px;
}

.message {
  margin-top: 10px;
}

.success {
  color: green;
}

.error {
  color: red;
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

  .clock-buttons {
    flex-direction: column;
    gap: 10px;
  }
}

@media (max-width: 480px) {
  h2 {
    font-size: 1.2em;
  }
}
</style>
