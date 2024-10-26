<template>
  <div class="dashboard">
    <!-- Hamburger Menu -->
    <HamburgerMenu />

    <!-- Top-right corner for Modify Password button -->

    <h2 class="dashboard-title">User Management Dashboard</h2>

    <!-- Display UserManager and TeamManager only if the user is an admin -->
    <user-manager v-if="user.role === 'admin'" />
    <team-manager v-if="user.role === 'admin'" :user-role="user.role" />

    <!-- TeamTracker component for managers only -->
    <team-tracker v-if="user.role === 'manager'" />

    <!-- Error message if the user is not authorized -->
    <div v-if="user.role === 'admin' && errorMessage">
      <p class="error">{{ errorMessage }}</p>
    </div>

    <!-- User Tracking for Employees and Managers -->
    <user-tracking v-if="['employee', 'manager'].includes(user.role)" :is-manager="user.role === 'manager'" />
  </div>
</template>

<script>
import UserTracking from './User/UserTracking.vue';
import { toastController } from '@ionic/vue';
import UserManager from './User/UserManager.vue';
import TeamManager from './TeamManager.vue';
import TeamTracker from './Team/TeamTracker.vue';  // Import the TeamTracker component
import HamburgerMenu from './HamburgerMenu.vue';

const apiUrl = process.env.VUE_APP_API_URL;

export default {
  name: 'UserDashboard',
  components: {
    UserManager,
    TeamManager,
    TeamTracker, // Register the TeamTracker component
    HamburgerMenu,
    UserTracking,
  },

  data() {
    return {
      user: {},
      errorMessage: '',
      hasActiveSession: false,
      workingTimes: [],
    };
  },
  methods: {
    async fetchUserRole() {
      const token = localStorage.getItem('token');
      const userId = localStorage.getItem('userId');

      try {
        const userResponse = await fetch(`${apiUrl}/users/${userId}`, {
          headers: { Authorization: `Bearer ${token}` },
        });

        if (!userResponse.ok) {
          throw new Error('Failed to fetch user data');
        }

        const userData = await userResponse.json();
        this.user = userData;
      } catch (error) {
        this.showToast('Error fetching user data: ' + error.message, 'danger');
      }
    },

    async fetchWorkingTimes() {
      const token = localStorage.getItem('token');
      const userId = localStorage.getItem('userId');

      try {
        const response = await fetch(`${apiUrl}/workingtime/${userId}`, {
          headers: { Authorization: `Bearer ${token}` },
        });

        if (!response.ok) {
          throw new Error('Failed to fetch working times');
        }

        const data = await response.json();
        this.workingTimes = data;
        this.hasActiveSession = data.some(wt => !wt.end);
      } catch (error) {
        this.showToast('Error fetching working times: ' + error.message, 'danger');
      }
    },

    refreshWorkingTimes() {
      this.fetchWorkingTimes();
    },

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
.dashboard {
  padding: 20px;
  height: 100vh;
  overflow-y: auto;
  background-color: #f4f4f4;
}

.top-right {
  position: absolute;
  top: 20px;
  right: 20px;
  z-index: 1001;
}

.dashboard-title {
  font-size: 2em;
  color: #333;
  text-align: center;
  margin-bottom: 30px;
}

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

.hamburger-menu {
  position: absolute;
  top: 20px;
  left: 20px;
  z-index: 1000;
}

@media (max-width: 768px) {
  .dashboard {
    padding: 10px;
  }

  h2 {
    font-size: 1.5em;
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
