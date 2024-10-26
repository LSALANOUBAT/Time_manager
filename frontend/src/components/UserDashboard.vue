<template>
  <div class="dashboard">
    <!-- Hamburger Menu -->
    <HamburgerMenu />

    <h2 class="dashboard-title">User Management Dashboard</h2>

    <!-- Display UserManager and TeamManager only if the user is not an employee -->
    <user-manager v-if="isAllowedToManageUsers" />
    <team-manager v-if="isAllowedToManageTeams" />

    <!-- Section Clock In / Clock Out for employees -->
    <div v-else class="clock-section">
      <h3>Manage Your Working Time</h3>
      <div class="clock-buttons">
        <ClockIn v-if="!hasActiveSession" @clock-in="refreshWorkingTimes" />
        <ClockOut v-if="hasActiveSession" @clock-out="refreshWorkingTimes" />
      </div>
    </div>

    <!-- Error message if the user is not authorized -->
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
    <working-time :user-id="user.id"></working-time>

    <!-- Chart Manager Section -->
    <chart-manager v-if="user.id" :selected-user-id="user.id"></chart-manager>

    <!-- Calendar Manager Section -->
    <calendar-manager v-if="user.id" :selected-user-id="user.id"></calendar-manager>
  </div>
</template>

<script>
import { toastController } from '@ionic/vue';
import UserManager from './User/UserManager.vue';
import TeamManager from './TeamManager.vue';
import HamburgerMenu from './HamburgerMenu.vue';
import ClockIn from './ClockIn.vue';
import ClockOut from './ClockOut.vue';

const apiUrl = process.env.VUE_APP_API_URL;

export default {
  name: 'UserDashboard',
  components: {
    UserManager,
    TeamManager,
    HamburgerMenu,
    ClockIn,
    ClockOut,
  },
  data() {
    return {
      user: {},
      isAllowedToManageUsers: false,
      isAllowedToManageTeams: false,
      clocks: [],
      workingTimes: [],
      errorMessage: '',
      hasActiveSession: false,
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

        // Set permissions based on user's role
        this.isAllowedToManageUsers = userData.role !== 'employee';
        this.isAllowedToManageTeams = userData.role === 'admin' || userData.role === 'manager';
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
