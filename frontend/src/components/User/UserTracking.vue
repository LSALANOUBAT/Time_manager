<template>
  <div class="user-tracking">
    <h2>Your Working Time Dashboard</h2>

    <!-- Summary Metrics Section -->
    <div v-if="totalHours !== null" class="summary">
      <h3>Total Hours This Month: {{ totalHours }} hours</h3>
      <p>Overtime Hours: {{ overtimeHours }} | Night Hours: {{ nightHours }}</p>
      <p>Undertime Sessions: {{ undertimeSessions }}</p>
    </div>

    <!-- Visualization Section with Charts -->
    <div class="chart-section">
      <div class="chart-container">
        <h4>Weekly Overtime Trend</h4>
        <canvas ref="overtimeChart"></canvas>
      </div>
      <div class="chart-container">
        <h4>Night Hours Distribution</h4>
        <canvas ref="nightHoursChart"></canvas>
      </div>
    </div>

    <!-- Working Time Calendar -->
    <calendar-manager :selected-user-id="user.id" />

    <!-- Detailed List of Working Times -->
    <section>
      <h3>Your Detailed Working Times</h3>
      <ul>
        <li v-for="wt in workingTimes" :key="wt.id">
          <strong>Start:</strong> {{ formatDate(wt.start) }} |
          <strong>End:</strong> {{ wt.end ? formatDate(wt.end) : "In Progress" }}
        </li>
      </ul>
    </section>
  </div>
</template>

<script>

import { Chart, registerables } from 'chart.js';

Chart.register(...registerables);

export default {
  name: 'UserTracking',

  data() {
    return {
      user: {},
      workingTimes: [],
      totalHours: null,
      overtimeHours: null,
      nightHours: null,
      undertimeSessions: null,
      overtimeData: [],
      nightHoursData: [],
      labels: [],
      errorMessage: '',
    };
  },
  methods: {
    async fetchUserDetails() {
      const token = localStorage.getItem('token');
      const userId = localStorage.getItem('userId');
      this.user.id = userId;

      // Fetch working times and metrics
      try {
        const [workingTimes, metrics] = await Promise.all([
          fetch(`${process.env.VUE_APP_API_URL}/workingtime/${userId}`, {
            headers: { Authorization: `Bearer ${token}` },
          }).then((res) => res.json()),
          this.fetchUserMetrics(userId, token),
        ]);

        this.workingTimes = workingTimes;
        this.generateChartData();
      } catch (error) {
        this.errorMessage = "Error fetching data: " + error.message;
      }
    },

    async fetchUserMetrics(userId, token) {
      try {
        const urls = [
          `/metrics/users_overtime_hours_sum`,
          `/metrics/users_night_hours_sum`,
          `/metrics/undertime_ratios`,
        ];

        const [overtime, night, undertime] = await Promise.all(
            urls.map((url) =>
                fetch(`${process.env.VUE_APP_API_URL}${url}`, {
                  headers: { Authorization: `Bearer ${token}` },
                }).then((res) => res.json())
            )
        );

        this.overtimeHours = overtime.overtime_hours_sum;
        this.nightHours = night.night_hours_sum;
        this.undertimeSessions = undertime.undertime_workingtimes;
        this.totalHours = this.calculateTotalHours();
      } catch (error) {
        this.errorMessage = "Error fetching metrics: " + error.message;
      }
    },

    generateChartData() {
      this.labels = this.workingTimes.map((wt, index) => `Session ${index + 1}`);
      this.overtimeData = this.workingTimes.map(wt => wt.overtime_hours || 0);
      this.nightHoursData = this.workingTimes.map(wt => wt.night_hours || 0);

      this.renderCharts();
    },

    renderCharts() {
      const overtimeCtx = this.$refs.overtimeChart.getContext('2d');
      const nightHoursCtx = this.$refs.nightHoursChart.getContext('2d');

      new Chart(overtimeCtx, {
        type: 'line',
        data: {
          labels: this.labels,
          datasets: [
            {
              label: 'Overtime Hours',
              data: this.overtimeData,
              backgroundColor: 'rgba(255, 99, 132, 0.2)',
              borderColor: 'rgba(255, 99, 132, 1)',
              borderWidth: 2,
            },
          ],
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            tooltip: { enabled: true },
          },
        },
      });

      new Chart(nightHoursCtx, {
        type: 'bar',
        data: {
          labels: this.labels,
          datasets: [
            {
              label: 'Night Hours',
              data: this.nightHoursData,
              backgroundColor: 'rgba(54, 162, 235, 0.2)',
              borderColor: 'rgba(54, 162, 235, 1)',
              borderWidth: 1,
            },
          ],
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            tooltip: { enabled: true },
          },
        },
      });
    },

    calculateTotalHours() {
      return this.workingTimes.reduce((acc, wt) => {
        const start = new Date(wt.start);
        const end = wt.end ? new Date(wt.end) : new Date();
        const duration = (end - start) / (1000 * 60 * 60);
        return acc + duration;
      }, 0).toFixed(2);
    },

    formatDate(dateStr) {
      const date = new Date(dateStr);
      return date.toLocaleString();
    },
  },
  mounted() {
    this.fetchUserDetails();
  },
};
</script>

<style scoped>
.user-tracking {
  padding: 20px;
  background-color: #f9f9f9;
  border-radius: 10px;
}

.user-tracking h2 {
  text-align: center;
  color: #333;
}

.summary {
  background-color: #e3f2fd;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
  text-align: center;
  font-size: 1.2em;
}

.chart-section {
  display: flex;
  justify-content: space-around;
  margin-top: 20px;
}

.chart-container {
  width: 45%;
  height: 250px;
  background: #fff;
  border-radius: 10px;
  padding: 15px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15);
  text-align: center;
}

.chart-container h4 {
  margin-bottom: 15px;
  font-size: 1.1em;
  color: #333;
}
</style>
