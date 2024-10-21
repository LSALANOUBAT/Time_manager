<template>
  <div class="chart-manager">
    <h2>Working Time Charts</h2>

    <!-- Render charts only if data is available -->
    <div v-if="lineChartData.datasets.length || barChartData.datasets.length || pieChartData.datasets.length">
      <line-chart v-if="lineChartData.datasets.length" :chart-data="lineChartData"></line-chart>
      <bar-chart v-if="barChartData.datasets.length" :chart-data="barChartData"></bar-chart>
      <pie-chart v-if="pieChartData.datasets.length" :chart-data="pieChartData"></pie-chart>
    </div>

    <!-- Display error message if any -->
    <div v-if="errorMessage" class="error-message">
      <p>Error: {{ errorMessage }}</p>
    </div>
  </div>
</template>

<script>
import { LineChart, BarChart, PieChart } from 'vue-chartjs';
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  LineElement,
  BarElement,
  PointElement,
  LinearScale,
  CategoryScale,
  ArcElement,
} from 'chart.js';

// Register chart.js components
ChartJS.register(Title, Tooltip, Legend, LineElement, BarElement, PointElement, LinearScale, CategoryScale, ArcElement);

const apiUrl = process.env.VUE_APP_API_URL;

export default {
  components: {
    LineChart,  // No need to extend the chart, use directly
    BarChart,   // No need to extend the chart, use directly
    PieChart,   // No need to extend the chart, use directly
  },
  data() {
    return {
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
    await this.fetchWorkingTimeData();
  },
  methods: {
    async fetchWorkingTimeData() {
      const userId = localStorage.getItem('userId');
      const token = localStorage.getItem('token');

      if (!userId) {
        this.errorMessage = "User ID not found. Please log in.";
        return;
      }

      // Define a date range (last 30 days for example)
      const endDate = new Date().toISOString();  // Today's date
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 30); // 30 days before today
      const startISO = startDate.toISOString();

      try {
        const response = await fetch(`${apiUrl}/workingtime/${userId}?start=${startISO}&end=${endDate}`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });

        if (!response.ok) {
          throw new Error(`Failed to fetch working time data: ${response.status}`);
        }

        const data = await response.json();
        this.transformChartData(data);
      } catch (error) {
        this.errorMessage = error.message;
      }
    },

    transformChartData(data) {
      const labels = data.map(item => new Date(item.start).toLocaleDateString());
      const durations = data.map(item => this.calculateDuration(item.start, item.end));

      this.lineChartData = {
        labels: labels,
        datasets: [{
          label: 'Working Time (Hours)',
          data: durations,
          borderColor: 'rgba(75, 192, 192, 1)',
          backgroundColor: 'rgba(75, 192, 192, 0.2)',
          fill: false,
        }],
      };

      this.barChartData = {
        labels: labels,
        datasets: [{
          label: 'Working Time (Hours)',
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
          backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF', '#FF9F40'],
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

.error-message {
  color: red;
  margin-top: 10px;
}
</style>
