<template>
  <div class="dashboard">
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
  </div>
</template>

<script>
const apiUrl = process.env.VUE_APP_API_URL;

export default {
  name: 'UserDashboard', // Renamed component to follow multi-word naming convention
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
