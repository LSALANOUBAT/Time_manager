<template>
  <div class="dashboard">
    <!-- Hamburger Menu -->
    <HamburgerMenu />

    <!-- Top-right corner for Modify Password button -->

    <h2 class="dashboard-title">User Management Dashboard</h2>

    <!-- Display UserManager and TeamManager only if the user is an admin -->
    <user-manager v-if="user.role === 'admin'" />
    <team-manager v-if="user.role === 'admin'" :user-role="user.role" />

    <!-- Error message if the user is not authorized -->
    <div v-if="user.role === 'admin' && errorMessage">
      <p class="error">{{ errorMessage }}</p>
    </div>

    <!-- User Tracking for Employees and Managers -->
    <user-tracking v-if="['employee', 'manager'].includes(user.role)" :is-manager="user.role === 'manager'" />
    <team-tracker v-if="user.role === 'manager'" />

    <!-- Display WorkingTimesGrid only for admin users -->
    <working-times-grid v-if="user.role === 'admin'" :working-times="workingTimes" @removeWorkingTime="removeWorkingTime" />
  </div>
</template>

<script>
import UserTracking from './User/UserTracking.vue';
import { toastController } from '@ionic/vue';
import UserManager from './User/UserManager.vue';
import TeamManager from './TeamManager.vue';
import WorkingTimesGrid from './WorkingTimesGrid.vue';
import TeamTracker from './Team/TeamTracker.vue';
import HamburgerMenu from './HamburgerMenu.vue';

const apiUrl = process.env.VUE_APP_API_URL;

export default {
  name: 'UserDashboard',
  components: {
    UserManager,
    TeamManager,
    WorkingTimesGrid,
    TeamTracker,
    HamburgerMenu,
    UserTracking,
  },

  data() {
    return {
      user: {},
      errorMessage: '',
      workingTimes: [],
    };
  },

  methods: {
    async fetchUserRole() {
      const token = localStorage.getItem('token');
      const userId = localStorage.getItem('userId');
      console.log("Fetching user role...");

      try {
        const userResponse = await fetch(`${apiUrl}/users/${userId}`, {
          headers: { Authorization: `Bearer ${token}` },
        });

        if (!userResponse.ok) {
          throw new Error('Failed to fetch user data');
        }

        const userData = await userResponse.json();
        this.user = userData;
        console.log("User data:", this.user);

        if (this.user.role === 'admin') {
          await this.fetchAllWorkingTimes();
        }
      } catch (error) {
        console.error("Error fetching user role:", error);
        this.showToast('Error fetching user data: ' + error.message, 'danger');
      }
    },

    async fetchAllWorkingTimes() {
      const token = localStorage.getItem('token');
      console.log("Fetching all working times...");

      try {
        const response = await fetch(`${apiUrl}/workingtime`, {
          headers: { Authorization: `Bearer ${token}` },
        });

        if (!response.ok) {
          throw new Error('Failed to fetch all working times');
        }

        this.workingTimes = await response.json();
        console.log("Working times data:", this.workingTimes);
      } catch (error) {
        console.error("Error fetching working times:", error);
        this.showToast('Error fetching working times: ' + error.message, 'danger');
      }
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
  },

  async mounted() {
    await this.fetchUserRole();
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
}

@media (max-width: 480px) {
  h2 {
    font-size: 1.2em;
  }
}
</style>
