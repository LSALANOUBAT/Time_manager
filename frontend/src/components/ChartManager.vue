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

    <!-- Render charts only if there is data -->
    <div v-if="lineChartData.datasets.length || barChartData.datasets.length || pieChartData.datasets.length">
      <line-chart v-if="lineChartData.datasets.length" :chart-data="lineChartData"></line-chart>
      <bar-chart v-if="barChartData.datasets.length" :chart-data="barChartData"></bar-chart>
      <pie-chart v-if="pieChartData.datasets.length" :chart-data="pieChartData"></pie-chart>
    </div>

    <!-- Display error message -->
    <div v-if="errorMessage" class="error-message">
      <p>Error: {{ errorMessage }}</p>
    </div>
  </div>
</template>

<script>
import { Line, Bar, Pie } from 'vue-chartjs';
import { Chart as ChartJS, Title, Tooltip, Legend, LineElement, BarElement, PointElement, LinearScale, CategoryScale, ArcElement } from 'chart.js';

ChartJS.register(Title, Tooltip, Legend, LineElement, BarElement, PointElement, LinearScale, CategoryScale, ArcElement);

const apiUrl = process.env.VUE_APP_API_URL;

export default {
  components: {
    LineChart: {
      extends: Line,
      props: ['chartData'],
      mounted() {
        this.renderChart(this.chartData, { responsive: true, maintainAspectRatio: false });
      },
    },
    BarChart: {
      extends: Bar,
      props: ['chartData'],
      mounted() {
        this.renderChart(this.chartData, { responsive: true, maintainAspectRatio: false });
      },
    },
    PieChart: {
      extends: Pie,
      props: ['chartData'],
      mounted() {
        this.renderChart(this.chartData, { responsive: true, maintainAspectRatio: false });
      },
    },
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
    await this.fetchUsers();
  },
  methods: {
    async fetchUsers() {
      try {
        const token = localStorage.getItem('token');
        const response = await fetch(`${apiUrl}/users`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });
        if (!response.ok) throw new Error(`Server error: ${response.status}`);

        this.users = await response.json();
      } catch (error) {
        console.error('Failed to fetch users:', error);
        this.errorMessage = 'Failed to fetch users. Please try again.';
      }
    },

    async fetchUserData() {
      if (!this.selectedUserId) {
        this.clearChartData();
        return;
      }

      const token = localStorage.getItem('token');

      try {
        const response = await fetch(`${apiUrl}/workingtime/${this.selectedUserId}`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });
        if (!response.ok) throw new Error(`Server error: ${response.status}`);

        const data = await response.json();
        if (data && data.length > 0) {
          this.transformChartData(data);
          this.errorMessage = null;
        } else {
          this.errorMessage = 'No working time data available for this user.';
          this.clearChartData();
        }
      } catch (error) {
        console.error('Failed to fetch working time data:', error);
        this.errorMessage = 'Failed to fetch chart data. Please try again.';
        this.clearChartData();
      }
    },

    clearChartData() {
      this.lineChartData = { labels: [], datasets: [] };
      this.barChartData = { labels: [], datasets: [] };
      this.pieChartData = { labels: [], datasets: [] };
    },

    transformChartData(data) {
      const sortedData = data.sort((a, b) => new Date(a.start) - new Date(b.start));

      const labels = sortedData.map((item) => new Date(item.start).toLocaleDateString());
      const durations = sortedData.map((item) => this.calculateDuration(item.start, item.end));

      this.lineChartData = {
        labels: labels,
        datasets: [{
          label: 'Working Time Duration (Hours)',
          data: durations,
          borderColor: 'rgba(75, 192, 192, 1)',
          backgroundColor: 'rgba(75, 192, 192, 0.2)',
          fill: false,
        }],
      };

      this.barChartData = {
        labels: labels,
        datasets: [{
          label: 'Working Time Duration (Hours)',
          data: durations,
          backgroundColor: 'rgba(153, 102, 255, 0.6)',
          borderColor: 'rgba(153, 102, 255, 1)',
          borderWidth: 1,
        }],
      };

      this.pieChartData = {
        labels: labels,
        datasets: [{
          label: 'Working Time Distribution',
          data: durations,
          backgroundColor: [
            '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF', '#FF9F40',
          ],
        }],
      };
    },

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
