<template>
    <div class="chart-container">
      <h3>Users Created Per Day</h3>
      <Bar v-if="chartData" :data="chartData" :options="chartOptions" />
    </div>
  </template>
  
  <script>
  import { Bar } from 'vue-chartjs';
  import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale } from 'chart.js';
  
  ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale);
  
  export default {
    name: 'UserHistogram',
    components: {
      Bar,
    },
    props: {
      users: {
        type: Array,
        required: true,
      },
    },
    computed: {
      chartData() {
        if (!this.users || this.users.length === 0) {
          return null;
        }
  
        // Group users by the day they were created
        const groupedByDay = this.users.reduce((acc, user) => {
          const createdDate = new Date(user.created_at).toLocaleDateString();
          acc[createdDate] = (acc[createdDate] || 0) + 1;
          return acc;
        }, {});
  
        const labels = Object.keys(groupedByDay);
        const data = Object.values(groupedByDay);
  
        return {
          labels,
          datasets: [
            {
              label: 'Users Created',
              data,
              backgroundColor: 'rgba(75, 192, 192, 0.5)',
            },
          ],
        };
      },
      chartOptions() {
        return {
          responsive: true,
          maintainAspectRatio: false,
          scales: {
            y: {
              beginAtZero: true,
              title: {
                display: true,
                text: 'Number of Users',
              },
            },
            x: {
              title: {
                display: true,
                text: 'Date',
              },
            },
          },
          plugins: {
            legend: {
              display: false,
            },
          },
        };
      },
    },
  };
  </script>
  
  <style scoped>
  .chart-container {
    width: 100%;
    height: 400px;
    margin-top: 20px;
  }
  </style>
  