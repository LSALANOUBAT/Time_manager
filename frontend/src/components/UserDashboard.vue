<template> 
  <div class="dashboard">
    <!-- Hamburger Menu -->
    <HamburgerMenu />

    <h2 class="dashboard-title">Welcome, {{ user.username }}!</h2>

    <!-- Clocks Section -->
    <section class="section-card">
      <h3>Your Clocks</h3>
      <ul>
        <li v-for="clock in clocks" :key="clock.id" class="clock-item">
          <strong>Status:</strong> {{ clock.status ? 'In' : 'Out' }} |
          <strong>Time:</strong> {{ formatDate(clock.time) }}
        </li>
      </ul>
    </section>

    <!-- Clock Manager Component -->
    <clock-manager :user-id="user.id" />

    <!-- Working Times Section -->
    <section class="section-card">
      <h3>Your Working Times</h3>
      <ul>
        <li v-for="wt in workingTimes" :key="wt.id" class="working-time-item">
          <strong>Start:</strong> {{ formatDate(wt.start) }} |
          <strong>End:</strong> {{ formatDate(wt.end) }}
        </li>
      </ul>
    </section>

    <!-- Working Time Management Component -->
    <working-time :user-id="user.id" />

    <!-- Chart Manager Section -->
    <chart-manager v-if="user.id" :selected-user-id="user.id" />

    <!-- Calendar Manager Section -->
    <calendar-manager v-if="user.id" :selected-user-id="user.id" />
  </div>
</template>

<script>
import ClockManager from './ClockManager.vue';
import ChartManager from './ChartManager.vue';
import WorkingTime from './WorkingTime.vue';
import CalendarManager from './CalendarManager.vue';
import HamburgerMenu from './HamburgerMenu.vue'; // Import HamburgerMenu component

const apiUrl = process.env.VUE_APP_API_URL;

export default {
  name: 'UserDashboard',
  components: {
    ClockManager,
    ChartManager,
    WorkingTime,
    CalendarManager,
    HamburgerMenu, // Register HamburgerMenu component
  },
  data() {
    return {
      user: {},
      clocks: [],
      workingTimes: [],
    };
  },
  methods: {
    async fetchUserData() {
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

        this.user = await userResponse.json();

        // Fetch clocks
        const clocksResponse = await fetch(`${apiUrl}/clocks/${userId}`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });

        if (!clocksResponse.ok) {
          throw new Error('Failed to fetch clocks');
        }

        this.clocks = await clocksResponse.json();

        // Fetch working times
        const workingTimesResponse = await fetch(`${apiUrl}/workingtime/${userId}`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });

        if (!workingTimesResponse.ok) {
          throw new Error('Failed to fetch working times');
        }

        this.workingTimes = await workingTimesResponse.json();
      } catch (error) {
        console.error(error.message);
      }
    },
    formatDate(dateStr) {
      const date = new Date(dateStr);
      return date.toLocaleString();
    },
  },
  mounted() {
    this.fetchUserData();
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

/* Sections en carte */
.section-card {
  background-color: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
  margin-bottom: 30px;
}

/* Style des éléments de la liste d'horloges */
.clock-item {
  font-size: 1.2em;
  padding: 10px;
  border-bottom: 1px solid #e0e0e0;
}

/* Style des éléments des heures de travail */
.working-time-item {
  font-size: 1.2em;
  padding: 10px;
  border-bottom: 1px solid #e0e0e0;
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

  section {
    margin-bottom: 15px;
  }

  ul {
    padding-left: 15px;
  }
}

@media (max-width: 480px) {
  h2 {
    font-size: 1.2em;
  }

  .form {
    width: 100%; /* Ensure full width for mobile */
  }
}
</style>
