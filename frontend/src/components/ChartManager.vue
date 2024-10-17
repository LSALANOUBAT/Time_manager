<template>
  <div class="chart-manager">
    <h2>Charts Overview</h2>
    <line-chart v-if="lineChartData.datasets" :data="lineChartData"></line-chart>
    <bar-chart v-if="barChartData.datasets" :data="barChartData"></bar-chart>
    <pie-chart v-if="pieChartData.datasets" :data="pieChartData"></pie-chart>

    <div v-if="errorMessage" class="error-message">
      <p>Error: {{ errorMessage }}</p>
    </div>
  </div>
</template>

<script>
import { Line, Bar, Pie } from 'vue-chartjs';

export default {
  components: {
    LineChart: Line,
    BarChart: Bar,
    PieChart: Pie,
  },
  data() {
    return {
      lineChartData: {},
      barChartData: {},
      pieChartData: {},
      errorMessage: null,
    };
  },
  async created() {
    try {
      const response = await fetch(`https://web.orbesle.fr:4000/api/workingtime`);
      if (!response.ok) {
        throw new Error(`Server error: ${response.status}`);
      }

      const data = await response.json();
      this.transformChartData(data);
    } catch (error) {
      console.error('Failed to fetch working time data:', error);
      this.errorMessage = 'Failed to fetch chart data. Please try again.';
    }
  },
  methods: {
    transformChartData(data) {
      // Example transformation for line chart data
      this.lineChartData = {
        labels: data.map(item => item.start), // Use working time start dates as labels
        datasets: [
          {
            label: 'Working Time Duration',
            data: data.map(item => this.calculateDuration(item.start, item.end)),
            fill: false,
          },
        ],
      };

      // Example transformation for bar chart data
      this.barChartData = {
        labels: data.map(item => item.start),
        datasets: [
          {
            label: 'Working Time Duration',
            data: data.map(item => this.calculateDuration(item.start, item.end)),
            backgroundColor: 'rgba(75, 192, 192, 0.2)',
            borderColor: 'rgba(75, 192, 192, 1)',
            borderWidth: 1,
          },
        ],
      };

      // Example transformation for pie chart data
      this.pieChartData = {
        labels: data.map(item => item.start),
        datasets: [
          {
            label: 'Working Time Distribution',
            data: data.map(item => this.calculateDuration(item.start, item.end)),
            backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF'],
          },
        ],
      };
    },
    calculateDuration(start, end) {
      const startTime = new Date(start);
      const endTime = new Date(end);
      return (endTime - startTime) / (1000 * 60 * 60); // Duration in hours
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
