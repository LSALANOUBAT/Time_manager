<template>
  <div class="team-manager">
    <h2>Team Management & Metrics</h2>

    <!-- Display Team Name -->
    <p v-if="teamId" class="team-id">Team Name: {{ teamId }}</p>

    <!-- Section to Add Unassigned Employee -->
    <div class="add-employee-section">
      <h3>Add Unassigned Employee</h3>
      <div class="employee-select">
        <select v-model="selectedEmployee" class="employee-dropdown">
          <option disabled value="">Select an Employee</option>
          <option v-for="employee in unassignedEmployees" :key="employee.id" :value="employee.id">
            {{ employee.username }}
          </option>
        </select>
        <button @click="addEmployeeToTeam" :disabled="!selectedEmployee" class="button-add-employee">Add to Team</button>
      </div>
    </div>

    <!-- Team Members Table -->
    <h3>Team Members</h3>
    <table class="team-members-table">
      <thead>
        <tr>
          <th>Username</th>
          <th>Role</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="member in teamMembers" :key="member.id">
          <td>{{ member.username }}</td>
          <td>{{ member.role }}</td>
          <td>
            <button @click="deleteMember(member.id)" class="button-delete-member">Remove</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Metrics Charts -->
    <div class="metrics">
      <div class="chart-container" v-for="(chart, index) in chartConfigs" :key="index">
        <h3>{{ chart.title }}</h3>
        <canvas :ref="chart.ref" width="200" height="200"></canvas>
        <p v-if="chart.ratio">{{ chart.label }}: {{ (chart.ratio * 100).toFixed(2) }}%</p>
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
      unassignedEmployees: [],
      selectedEmployee: null,
      charts: {},
      chartConfigs: [
        { title: 'Overtime vs. Regular Hours', ref: 'overtimeChart', label: 'Overtime Ratio', ratio: null },
        { title: 'Night Work Ratio', ref: 'nightRatioChart', label: 'Night Work Ratio', ratio: null },
        { title: 'Undertime vs. On-Time Ratio', ref: 'undertimeChart', label: 'Undertime Ratio', ratio: null },
        { title: 'Daily Working Times', ref: 'dailyWorkingTimeChart' }
      ],
    };
  },
  methods: {
    async fetchMetrics() {
      const headers = { Authorization: `Bearer ${localStorage.getItem('token')}` };

      try {
        const responses = await Promise.all([
          fetch(`${process.env.VUE_APP_API_URL}/metrics/overtime_ratios`, { headers }),
          fetch(`${process.env.VUE_APP_API_URL}/metrics/night_ratios`, { headers }),
          fetch(`${process.env.VUE_APP_API_URL}/metrics/undertime_ratios`, { headers }),
          fetch(`${process.env.VUE_APP_API_URL}/metrics/time_per_over_overtime`, { headers })
        ]);

        const [overtimeData, nightData, undertimeData, dailyWorkingData] = await Promise.all(
          responses.map(response => response.ok ? response.json() : {})
        );

        this.chartConfigs[0].ratio = overtimeData.overtime_ratio || 0;
        this.chartConfigs[1].ratio = nightData.night_ratio || 0;
        this.chartConfigs[2].ratio = undertimeData.undertime_ratio || 0;

        this.initializeCharts(overtimeData, nightData, undertimeData, dailyWorkingData);
      } catch (error) {
        console.error("Error fetching metrics:", error);
        this.showToast("Error fetching metrics: " + error.message, "danger");
      }
    },
    initializeCharts(overtimeData, nightData, undertimeData, dailyWorkingData) {
      const chartDefinitions = [
        {
          ref: 'overtimeChart',
          type: 'doughnut',
          data: [overtimeData.overtime_hours_sum || 0, overtimeData.total_hours_sum || 0],
          labels: ['Overtime Hours', 'Regular Hours']
        },
        {
          ref: 'nightRatioChart',
          type: 'pie',
          data: [nightData.night_hours_sum || 0, nightData.total_hours_sum || 0],
          labels: ['Night Hours', 'Day Hours']
        },
        {
          ref: 'undertimeChart',
          type: 'pie',
          data: [undertimeData.undertime_workingtimes || 0, undertimeData.total_workingtimes || 0],
          labels: ['Undertime', 'On-Time']
        },
        {
          ref: 'dailyWorkingTimeChart',
          type: 'bar',
          data: dailyWorkingData.daily_working_times?.map(item => item.count) || [],
          labels: dailyWorkingData.daily_working_times?.map(item => item.date) || [],
          label: 'Working Times Count'
        }
      ];

      chartDefinitions.forEach((chart) => {
        if (this.$refs[chart.ref] && !this.charts[chart.ref]) {
          this.charts[chart.ref] = new Chart(this.$refs[chart.ref], {
            type: chart.type,
            data: {
              labels: chart.labels,
              datasets: [{
                label: chart.label || '',
                data: chart.data,
                backgroundColor: ['#ff6347', '#36a2eb', '#42a5f5', '#66bb6a'],
                borderColor: '#42a5f5',
                fill: chart.type !== 'line',
              }]
            },
            options: {
              responsive: true,
              maintainAspectRatio: false,
              plugins: {
                legend: {
                  display: chart.type !== 'bar'
                }
              }
            }
          });
        }
      });
    },

    async fetchUnassignedEmployees() {
      const headers = { Authorization: `Bearer ${localStorage.getItem('token')}` };
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/users/unsigned_employee`, { headers });
        if (!response.ok) throw new Error('Failed to fetch unassigned employees');
        this.unassignedEmployees = await response.json();
      } catch (error) {
        this.showToast("Error fetching unassigned employees: " + error.message, "danger");
      }
    },

    async addEmployeeToTeam() {
      const headers = { Authorization: `Bearer ${localStorage.getItem('token')}` };
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/team_members/${this.selectedEmployee}/team/`, {
          method: 'POST',
          headers
        });
        if (!response.ok) throw new Error('Failed to add employee to the team');
        this.fetchTeamMembers();
        this.fetchUnassignedEmployees();
        this.selectedEmployee = null;
        this.showToast("Employee added to team successfully!", "success");
      } catch (error) {
        this.showToast("Error adding employee: " + error.message, "danger");
      }
    },

    async fetchTeamMembers() {
      const headers = { Authorization: `Bearer ${localStorage.getItem('token')}` };
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/team_members`, { headers });
        if (!response.ok) throw new Error('Failed to fetch team members');
        const data = await response.json();
        this.teamMembers = data.members || [];
        this.teamId = data.team_id || data.team;
      } catch (error) {
        this.showToast("Error fetching team members: " + error.message, "danger");
      }
    },

    async deleteMember(userId) {
      const headers = { Authorization: `Bearer ${localStorage.getItem('token')}` };
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/team_members/${userId}/team/`, {
          method: 'DELETE',
          headers
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
        color
      });
      return toast.present();
    }
  },

  mounted() {
    this.fetchTeamMembers();
    this.fetchUnassignedEmployees();
    this.fetchMetrics();
  }
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

.add-employee-section {
  background-color: #f9f9f9;
  padding: 15px;
  margin-bottom: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.employee-select {
  display: flex;
  align-items: center;
  gap: 10px;
}

.employee-dropdown {
  padding: 8px;
  border: 1px solid #ccc;
  border-radius: 4px;
}

.button-add-employee {
  background-color: #007bff;
  color: white;
  padding: 8px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.button-add-employee:hover {
  background-color: #0056b3;
}

.team-members-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 20px;
}

.team-members-table th,
.team-members-table td {
  padding: 10px;
  text-align: left;
  border-bottom: 1px solid #ddd;
}

.team-members-table th {
  background-color: #f4f4f4;
  font-weight: bold;
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

.metrics {
  display: flex;
  flex-wrap: wrap;
  gap: 25px;
  margin-top: 25px;
  justify-content: space-around;
}

.chart-container {
  flex: 1 1 48%;
  max-width: 400px;
  min-width: 300px;
  height: 400px;
  background-color: #fff;
  padding: 25px;
  border-radius: 8px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.chart-container canvas {
  width: 100% !important;
  height: auto !important;
  max-height: 300px;
}
</style>
