<template>
  <div class="chart-manager">
    <h2>Charts Overview</h2>

    <!-- User selection dropdown -->
    <div class="user-selector">
      <label for="user-select">Select User: </label>
      <select id="user-select" v-model="selectedUserId" @change="fetchUserData">
        <option value="">--Select a user--</option>
        <option v-for="user in users" :key="user.id" :value="user.id">
          {{ user.username }}
        </option>
      </select>
    </div>

    <!-- Charts -->
    <line-chart v-if="lineChartData.datasets.length" :data="lineChartData"></line-chart>
    <bar-chart v-if="barChartData.datasets.length" :data="barChartData"></bar-chart>
    <pie-chart v-if="pieChartData.datasets.length" :data="pieChartData"></pie-chart>

    <!-- Error message -->
    <div v-if="errorMessage" class="error-message">
      <p>Error: {{ errorMessage }}</p>
    </div>
  </div>
</template>

<script>
// Import chart components
import { Line, Bar, Pie } from 'vue-chartjs';

export default {
  components: {
    LineChart: Line,
    BarChart: Bar,
    PieChart: Pie,
  },
  data() {
    return {
      users: [], // List of users
      selectedUserId: '', // Currently selected user
      lineChartData: {
        labels: [],
        datasets: [],
      },
      barChartData: {
        labels: [],
        datasets: [],
      },
      pieChartData: {
        labels: [],
        datasets: [],
      },
      errorMessage: null,
    };
  },
  async created() {
    await this.fetchUsers(); // Fetch users when component is created
  },
  methods: {
    // Fetch the list of users from the API
    async fetchUsers() {
      try {
        const response = await fetch('http://localhost:4000/api/users'); // Adjust API endpoint if needed

        if (!response.ok) {
          throw new Error(Server error: ${response.status});
        }

        const data = await response.json();
        this.users = data; // Store the list of users
      } catch (error) {
        console.error('Failed to fetch users:', error);
        this.errorMessage = 'Failed to fetch users. Please try again.';
      }
    },

    // Fetch working time data for the selected user
    async fetchUserData() {
      if (!this.selectedUserId) {
        this.errorMessage = 'Please select a user.';
        return;
      }

      try {
        const response = await fetch(http://localhost:4000/api/workingtime/${this.selectedUserId});

        if (!response.ok) {
          throw new Error(Server error: ${response.status});
        }

        const data = await response.json();
        if (data && data.length > 0) {
          this.transformChartData(data); // Transform data for the charts
        } else {
          this.errorMessage = 'No working time data available for this user.';
          this.clearChartData();
        }
      } catch (error) {
        console.error('Failed to fetch working time data:', error);
        this.errorMessage = 'Failed to fetch chart data. Please try again.';
      }
    },

    // Function to clear chart data when no data is available
    clearChartData() {
      this.lineChartData = { labels: [], datasets: [] };
      this.barChartData = { labels: [], datasets: [] };
      this.pieChartData = { labels: [], datasets: [] };
    },

    // Transform the fetched working time data for charts
    transformChartData(data) {
      const sortedData = data.sort((a, b) => new Date(a.start) - new Date(b.start));

      const labels = sortedData.map((item) => new Date(item.start).toLocaleDateString());
      const durations = sortedData.map((item) => this.calculateDuration(item.start, item.end));

      // Line Chart Data
      this.lineChartData = {
        labels: labels,
        datasets: [
          {
            label: 'Working Time Duration (Hours)',
            data: durations,
            borderColor: 'rgba(75, 192, 192, 1)',
            backgroundColor: 'rgba(75, 192, 192, 0.2)',
            fill: false,
          },
        ],
      };

      // Bar Chart Data
      this.barChartData = {
        labels: labels,
        datasets: [
          {
            label: 'Working Time Duration (Hours)',
            data: durations,
            backgroundColor: 'rgba(153, 102, 255, 0.6)',
            borderColor: 'rgba(153, 102, 255, 1)',
            borderWidth: 1,
          },
        ],
      };

      // Pie Chart Data
      this.pieChartData = {
        labels: labels,
        datasets: [
          {
            label: 'Working Time Distribution',
            data: durations,
            backgroundColor: [
              '#FF6384',
              '#36A2EB',
              '#FFCE56',
              '#4BC0C0',
              '#9966FF',
              '#FF9F40',
            ],
          },
        ],
      };
    },

    // Calculate duration in hours between start and end times
    calculateDuration(start, end) {
      const startTime = new Date(start);
      const endTime = new Date(end);
      return (endTime - startTime) / (1000 * 60 * 60); // Convert milliseconds to hours
    },
  },
};
</script>

<style scoped>
.chart-manager {
  margin: 20px;
}

.user-selector {
  margin-bottom: 20px;
}

.error-message {
  color: red;
  margin-top: 10px;
}
</style>