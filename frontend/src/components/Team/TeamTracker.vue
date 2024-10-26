<template>
  <div class="team-manager">
    <h2>Team Management & Metrics</h2>

    <!-- Display Team ID -->
    <p v-if="teamId" class="team-id">Team ID: {{ teamId }}</p>
    <h3>Team Members</h3>
    <ul class="member-list">
      <li v-for="member in teamMembers" :key="member.id">
        ID: {{ member.user_id }} - {{ member.username }} ({{ member.role }})
        <button @click="editMember(member)" class="button-edit-member">Edit</button>
        <button @click="deleteMember(member.id)" class="button-delete-member">Remove</button>
      </li>
    </ul>

    <!-- Graphs for Metrics -->
    <div class="metrics">
      <div class="chart-container" v-for="(chart, index) in chartConfigs" :key="index">
        <h3>{{ chart.title }}</h3>
        <canvas :ref="chart.ref"></canvas>
        <p v-if="chart.ratio"> {{ chart.label }}: {{ (chart.ratio * 100).toFixed(2) }}%</p>
      </div>
    </div>
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
      hoursPerWorkingTime: [],
      chartConfigs: [
        { title: 'Overtime vs. Regular Hours', ref: 'overtimeChart', label: 'Overtime Ratio', ratio: null },
        { title: 'Night Work Ratio', ref: 'nightRatioChart', label: 'Night Work Ratio', ratio: null },
        { title: 'Undertime vs. On-Time Ratio', ref: 'undertimeChart', label: 'Undertime Ratio', ratio: null },
        { title: 'Daily Working Times', ref: 'dailyWorkingTimeChart' },
        { title: 'Hours Worked per Day', ref: 'hoursPerDayChart' },
      ],
    };
  },
  methods: {
    editMember(member) {
      console.log("Editing member:", member); // Log to verify the member details are passed
      // Emit the event to the parent with member data, or set up your own editing UI logic here
      this.$emit("editMember", member); // To handle in parent component
    },

    async fetchMetrics() {
      const headers = { Authorization: `Bearer ${localStorage.getItem('token')}` };
      console.log("Fetching metrics data...");

      try {
        const [overtimeResponse, nightResponse, undertimeResponse, dailyWorkingResponse, hoursPerDayResponse] = await Promise.all([
          fetch(`${process.env.VUE_APP_API_URL}/metrics/overtime_ratios`, { headers }),
          fetch(`${process.env.VUE_APP_API_URL}/metrics/night_ratios`, { headers }),
          fetch(`${process.env.VUE_APP_API_URL}/metrics/undertime_ratios`, { headers }),
          fetch(`${process.env.VUE_APP_API_URL}/metrics/time_per_over_overtime`, { headers }),
          fetch(`${process.env.VUE_APP_API_URL}/metrics/users_hours_per_working_time`, { headers })
        ]);

        this.overtimeData = overtimeResponse.ok ? await overtimeResponse.json() : {};
        this.nightData = nightResponse.ok ? await nightResponse.json() : {};
        this.undertimeData = undertimeResponse.ok ? await undertimeResponse.json() : {};
        this.dailyWorkingTimes = dailyWorkingResponse.ok ? (await dailyWorkingResponse.json()).daily_working_times : [];
        this.hoursPerWorkingTime = hoursPerDayResponse.ok ? await hoursPerDayResponse.json() : [];

        this.chartConfigs[0].ratio = this.overtimeData.overtime_ratio || 0;
        this.chartConfigs[1].ratio = this.nightData.night_ratio || 0;
        this.chartConfigs[2].ratio = this.undertimeData.undertime_ratio || 0;

        this.renderCharts();
      } catch (error) {
        console.error("Error fetching metrics:", error);
        this.showToast("Error fetching metrics: " + error.message, "danger");
      }
    },

    async fetchTeamMembers() {
      const headers = { Authorization: `Bearer ${localStorage.getItem('token')}` };
      console.log("Fetching team members...");

      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/team_members`, { headers });
        if (!response.ok) throw new Error('Failed to fetch team members');

        const data = await response.json();
        console.log("Fetched team members:", data);
        this.teamMembers = data.members || [];
        this.teamId = data.team_id || data.team;
      } catch (error) {
        console.error("Error fetching team members:", error);
        this.showToast("Error fetching team members: " + error.message, "danger");
      }
    },

    renderCharts() {
      const chartData = [
        { ref: 'overtimeChart', data: [this.overtimeData.overtime_ratio, this.overtimeData.total_ratio], labels: ['Overtime', 'Regular Hours'] },
        { ref: 'nightRatioChart', data: [this.nightData.night_ratio, this.nightData.total_ratio], labels: ['Night Hours', 'Day Hours'] },
        { ref: 'undertimeChart', data: [this.undertimeData.undertime_ratio, this.undertimeData.on_time_ratio], labels: ['Undertime', 'On-Time'] },
        { ref: 'dailyWorkingTimeChart', data: this.dailyWorkingTimes.map(item => item.count), labels: this.dailyWorkingTimes.map(item => item.date) },
        { ref: 'hoursPerDayChart', data: this.hoursPerWorkingTime.map(item => item.hours), labels: this.hoursPerWorkingTime.map(item => item.date) },
      ];

      chartData.forEach((chart, index) => {
        if (this.$refs[chart.ref]) {
          new Chart(this.$refs[chart.ref], {
            type: index === 3 ? 'bar' : index === 4 ? 'line' : 'pie',
            data: {
              labels: chart.labels,
              datasets: [{
                data: chart.data,
                backgroundColor: index < 3 ? ['#ff6347', '#36a2eb'] : ['#42a5f5', '#66bb6a'],
              }]
            }
          });
        }
      });
    },

    async deleteMember(userId) {
      const headers = { Authorization: `Bearer ${localStorage.getItem('token')}` };
      console.log(`Deleting member with ID: ${userId}`);

      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/team_members/${userId}/team/`, {
          method: 'DELETE',
          headers,
        });

        if (!response.ok) throw new Error('Failed to delete member');

        this.teamMembers = this.teamMembers.filter((member) => member.id !== userId);
        this.showToast("Member removed successfully!", "success");
      } catch (error) {
        console.error("Error deleting member:", error);
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
.button-edit-member {
  background-color: #4CAF50;
  color: white;
  padding: 5px 10px;
  margin-right: 10px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
.button-edit-member:hover {
  background-color: #388E3C;
}
</style>
