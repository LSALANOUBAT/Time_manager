<template>
  <div class="user-tracking">
    <h2>Your Working Time Dashboard</h2>

    <!-- Clock In/Out Component -->
    <ClockInOut
        :userId="user.id"
        :token="token"
        @session-updated="fetchUserDetails"
    />
    <!-- Summary Metrics Section -->
    <div v-if="totalHours !== null" class="summary">
      <h3>Total Hours This Month: {{ totalHours }} hours</h3>
      <p>Overtime Hours: {{ overtimeHours }} | Night Hours: {{ nightHours }}</p>
      <p>Undertime Sessions: {{ undertimeSessions }}</p>
    </div>

    <!-- Visualization Section with Charts -->
    <div class="chart-section">
      <div class="chart-container">
        <h4>Hours Worked Over Time</h4>
        <canvas ref="hoursWorkedChart"></canvas>
      </div>
      <div class="chart-container">
        <h4>Overtime and Night Hours</h4>
        <canvas ref="overtimeNightChart"></canvas>
      </div>
    </div>

    <!-- Detailed List of Working Times -->
    <section>
      <h3>Your Detailed Working Times</h3>
      <ul>
        <li v-for="wt in workingTimes" :key="wt.id">
          <strong>Date:</strong> {{ formatDate(wt.start, 'date') }} |
          <strong>Start:</strong> {{ formatDate(wt.start, 'time') }} |
          <strong>End:</strong> {{ wt.end ? formatDate(wt.end, 'time') : "In Progress" }} |
          <strong>Hours Worked:</strong> {{ wt.hours_worked.toFixed(2) }}
        </li>
      </ul>
    </section>
  </div>
</template>

<script>
import { Chart, registerables } from 'chart.js';
import ClockInOut from './ClockInOut.vue'; // Adjust path if needed
Chart.register(...registerables);

export default {
  name: 'UserTracking',
  components: {
    ClockInOut,
  },
  data() {
    return {
      user: {},
      token: localStorage.getItem('token'),
      workingTimes: [],
      totalHours: null,
      overtimeHours: null,
      nightHours: null,
      undertimeSessions: null,
      errorMessage: '',
    };
  },
  methods: {
    async fetchUserDetails() {
      const token = localStorage.getItem('token');
      const userId = localStorage.getItem('userId');
      this.user.id = userId;

      try {
        // Fetch working times
        const workingTimesResponse = await fetch(`${process.env.VUE_APP_API_URL}/workingtime/${userId}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (!workingTimesResponse.ok) throw new Error('Failed to fetch working times');
        this.workingTimes = await workingTimesResponse.json();

        // Fetch user metrics
        await this.fetchUserMetrics(token);

        // Generate charts
        this.generateChartData();
      } catch (error) {
        this.errorMessage = "Error fetching data: " + error.message;
      }
    },

    async fetchUserMetrics(token) {
      try {
        const [overtime, night, undertime] = await Promise.all([
          fetch(`${process.env.VUE_APP_API_URL}/metrics/users_overtime_hours_sum`, {
            headers: { Authorization: `Bearer ${token}` },
          }).then((res) => res.json()),
          fetch(`${process.env.VUE_APP_API_URL}/metrics/users_night_hours_sum`, {
            headers: { Authorization: `Bearer ${token}` },
          }).then((res) => res.json()),
          fetch(`${process.env.VUE_APP_API_URL}/metrics/undertime_ratios`, {
            headers: { Authorization: `Bearer ${token}` },
          }).then((res) => res.json()),
        ]);

        this.overtimeHours = overtime.overtime_hours_sum.toFixed(2);
        this.nightHours = night.night_hours_sum.toFixed(2);
        this.undertimeSessions = undertime.undertime_workingtimes || 0;
        this.totalHours = this.calculateTotalHours();
      } catch (error) {
        this.errorMessage = "Error fetching metrics: " + error.message;
      }
    },

    generateChartData() {
      // Prepare data for charts
      const labels = this.workingTimes.map(wt => this.formatDate(wt.start, 'date'));
      const hoursWorkedData = this.workingTimes.map(wt => wt.hours_worked || 0);
      const overtimeData = this.workingTimes.map(wt => wt.overtime_hours || 0);
      const nightHoursData = this.workingTimes.map(wt => wt.night_hours || 0);

      // Render charts
      this.renderHoursWorkedChart(labels, hoursWorkedData);
      this.renderOvertimeNightChart(labels, overtimeData, nightHoursData);
    },

    renderHoursWorkedChart(labels, data) {
      const ctx = this.$refs.hoursWorkedChart.getContext('2d');
      new Chart(ctx, {
        type: 'line',
        data: {
          labels,
          datasets: [
            {
              label: 'Hours Worked',
              data,
              backgroundColor: 'rgba(75, 192, 192, 0.2)',
              borderColor: 'rgba(75, 192, 192, 1)',
              borderWidth: 2,
              fill: true,
            },
          ],
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          scales: {
            x: {
              title: { display: true, text: 'Date' },
            },
            y: {
              title: { display: true, text: 'Hours Worked' },
              beginAtZero: true,
            },
          },
          plugins: {
            tooltip: { enabled: true },
          },
        },
      });
    },

    renderOvertimeNightChart(labels, overtimeData, nightHoursData) {
      const ctx = this.$refs.overtimeNightChart.getContext('2d');
      new Chart(ctx, {
        type: 'bar',
        data: {
          labels,
          datasets: [
            {
              label: 'Overtime Hours',
              data: overtimeData,
              backgroundColor: 'rgba(255, 159, 64, 0.6)',
              borderColor: 'rgba(255, 159, 64, 1)',
              borderWidth: 1,
            },
            {
              label: 'Night Hours',
              data: nightHoursData,
              backgroundColor: 'rgba(54, 162, 235, 0.6)',
              borderColor: 'rgba(54, 162, 235, 1)',
              borderWidth: 1,
            },
          ],
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          scales: {
            x: {
              stacked: true,
              title: { display: true, text: 'Date' },
            },
            y: {
              stacked: true,
              title: { display: true, text: 'Hours' },
              beginAtZero: true,
            },
          },
          plugins: {
            tooltip: { enabled: true },
          },
        },
      });
    },

    calculateTotalHours() {
      const total = this.workingTimes.reduce((acc, wt) => acc + (wt.hours_worked || 0), 0);
      return total.toFixed(2);
    },

    formatDate(dateStr, type = 'datetime') {
      const options = type === 'date' ? { year: 'numeric', month: 'short', day: 'numeric' } :
          type === 'time' ? { hour: '2-digit', minute: '2-digit' } :
              { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' };
      const date = new Date(dateStr);
      return date.toLocaleString(undefined, options);
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
  background-color: #fff;
  border-radius: 10px;
}

.user-tracking h2 {
  text-align: center;
  color: #333;
}

.summary {
  background-color: #e0f7fa;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
  text-align: center;
  font-size: 1.1em;
}

.chart-section {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-around;
  margin-top: 20px;
}

.chart-container {
  width: 100%;
  max-width: 600px;
  height: 300px;
  background: #fff;
  border-radius: 10px;
  padding: 15px;
  margin: 10px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
}

.chart-container h4 {
  margin-bottom: 10px;
  font-size: 1em;
  color: #333;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  background: #f9f9f9;
  margin-bottom: 8px;
  padding: 10px;
  border-radius: 5px;
}

li strong {
  color: #555;
}

@media (max-width: 768px) {
  .chart-container {
    width: 100%;
  }
}
</style>
