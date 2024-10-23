<template>
  <div class="dashboard">
    <!-- Hamburger Menu -->
    <HamburgerMenu />

    <h2>Welcome, {{ user.username }}!</h2>

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
.dashboard {
  padding: 20px;
}

section {
  margin-bottom: 20px;
}
</style>
