<template>
  <div class="team-manager">
    <h2>Team Management & Metrics</h2>

    <!-- Display Team ID -->
    <p v-if="teamId" class="team-id">Team ID: {{ teamId }}</p>

    <!-- Graphs for Metrics -->
    <div class="metrics">
      <div class="chart-container">
        <h3>Overtime vs. Regular Hours</h3>
        <canvas ref="overtimeChart"></canvas>
        <p>Overtime Ratio: {{ (overtimeData.overtime_ratio * 100).toFixed(2) }}%</p>
      </div>
      <div class="chart-container">
        <h3>Night Work Ratio</h3>
        <canvas ref="nightRatioChart"></canvas>
        <p>Night Work Ratio: {{ (nightData.night_ratio * 100).toFixed(2) }}%</p>
      </div>
      <div class="chart-container">
        <h3>Undertime vs. On-Time Ratio</h3>
        <canvas ref="undertimeChart"></canvas>
        <p>Undertime Ratio: {{ (undertimeData.undertime_ratio * 100).toFixed(2) }}%</p>
      </div>
      <div class="chart-container">
        <h3>Daily Working Times</h3>
        <canvas ref="dailyWorkingTimeChart"></canvas>
      </div>
      <div class="chart-container">
        <h3>Hours Worked per Day</h3>
        <canvas ref="hoursPerDayChart"></canvas>
      </div>
    </div>

    <!-- List of team members -->
    <h3>Team Members</h3>
    <ul class="member-list">
      <li v-for="member in teamMembers" :key="member.id">
        {{ member.username }} ({{ member.role }})
        <button @click="deleteMember(member.id)" class="button-delete-member">Remove</button>
      </li>
    </ul>
  </div>
</template>

<script>
import { toastController } from '@ionic/vue';
import { Chart } from 'chart.js';

export default {
  name: "TeamTracker",
  data() {
    return {
      teamId: null,
      teamMembers: [],
      overtimeData: {},
      nightData: {},
      undertimeData: {},
      dailyWorkingTimes: [],
      hoursPerWorkingTime: []
    };
  },
  methods: {
    async fetchMetrics() {
      const headers = { Authorization: `Bearer ${localStorage.getItem('token')}` };

      try {
        const [overtimeResponse, nightResponse, undertimeResponse, dailyWorkingResponse, hoursPerDayResponse] = await Promise.all([
          fetch(`${process.env.VUE_APP_API_URL}/metrics/overtime_ratios`, { headers }),
          fetch(`${process.env.VUE_APP_API_URL}/metrics/night_ratios`, { headers }),
          fetch(`${process.env.VUE_APP_API_URL}/metrics/undertime_ratios`, { headers }),
          fetch(`${process.env.VUE_APP_API_URL}/metrics/time_per_over_overtime`, { headers }),
          fetch(`${process.env.VUE_APP_API_URL}/metrics/users_hours_per_working_time`, { headers })
        ]);

        if (overtimeResponse.ok) this.overtimeData = await overtimeResponse.json();
        if (nightResponse.ok) this.nightData = await nightResponse.json();
        if (undertimeResponse.ok) this.undertimeData = await undertimeResponse.json();
        if (dailyWorkingResponse.ok) this.dailyWorkingTimes = (await dailyWorkingResponse.json()).daily_working_times;
        if (hoursPerDayResponse.ok) this.hoursPerWorkingTime = await hoursPerDayResponse.json();

        this.renderCharts();
      } catch (error) {
        this.showToast("Error fetching metrics: " + error.message, "danger");
      }
    },

    async fetchTeamMembers() {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/team_members`, {
          headers: {
            Authorization: `Bearer ${localStorage.getItem('token')}`,
          },
        });

        if (!response.ok) throw new Error('Failed to fetch team members');

        const data = await response.json();
        this.teamMembers = data.members;
        this.teamId = data.team_id || data.team;
      } catch (error) {
        this.showToast("Error fetching team members: " + error.message, "danger");
      }
    },

    renderCharts() {
      // Overtime vs. Regular Hours Chart
      new Chart(this.$refs.overtimeChart, {
        type: 'doughnut',
        data: {
          labels: ['Overtime', 'Regular Hours'],
          datasets: [{
            data: [this.overtimeData.overtime_ratio, this.overtimeData.total_ratio],
            backgroundColor: ['#ff6347', '#36a2eb']
          }]
        }
      });

      // Night Work Ratio Chart
      new Chart(this.$refs.nightRatioChart, {
        type: 'pie',
        data: {
          labels: ['Night Hours', 'Day Hours'],
          datasets: [{
            data: [this.nightData.night_ratio, this.nightData.total_ratio],
            backgroundColor: ['#ffa500', '#4bc0c0']
          }]
        }
      });

      // Undertime vs. On-Time Chart
      new Chart(this.$refs.undertimeChart, {
        type: 'pie',
        data: {
          labels: ['Undertime', 'On-Time'],
          datasets: [{
            data: [this.undertimeData.undertime_ratio, this.undertimeData.on_time_ratio],
            backgroundColor: ['#ffcd56', '#ff9f40']
          }]
        }
      });

      // Daily Working Times Chart
      new Chart(this.$refs.dailyWorkingTimeChart, {
        type: 'bar',
        data: {
          labels: this.dailyWorkingTimes.map(item => item.date),
          datasets: [{
            label: 'Daily Working Times',
            data: this.dailyWorkingTimes.map(item => item.count),
            backgroundColor: '#42a5f5'
          }]
        }
      });

      // Hours Worked per Day Chart
      new Chart(this.$refs.hoursPerDayChart, {
        type: 'line',
        data: {
          labels: this.hoursPerWorkingTime.map(item => item.date),
          datasets: [{
            label: 'Hours per Day',
            data: this.hoursPerWorkingTime.map(item => item.hours),
            backgroundColor: '#66bb6a'
          }]
        }
      });
    },

    async deleteMember(userId) {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/team_members/${userId}/team/`, {
          method: 'DELETE',
          headers: {
            Authorization: `Bearer ${localStorage.getItem('token')}`,
          },
        });

        if (!response.ok) throw new Error('Failed to delete member');

        this.teamMembers = this.teamMembers.filter((member) => member.id !== userId);
        this.showToast("Member removed successfully!", "success");
      } catch (error) {
        this.showToast("Error deleting member: " + error.message, "danger");
      }
    },

    async showToast(message, color) {
      const toast = await toastController.create({
        message,
        duration: 3000,
        color,
      });
      return toast.present();
    }
  },
  mounted() {
    this.fetchTeamMembers();
    this.fetchMetrics();
  },
};
</script>

<style scoped>
.team-manager {
  padding: 20px;
}
.team-id {
  font-weight: bold;
  margin-bottom: 10px;
}
.metrics {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  margin-bottom: 20px;
}
.chart-container {
  flex: 1 1 45%;
  background-color: #fff;
  padding: 15px;
  border-radius: 8px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  margin-bottom: 20px;
}
.button-delete-member {
  background-color: #ff6347;
  color: white;
  padding: 5px 10px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
.button-delete-member:hover {
  background-color: #d9452a;
}
</style>
