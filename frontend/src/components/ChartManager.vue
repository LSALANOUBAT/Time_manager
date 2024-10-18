<template>
  <div class="chart-manager">
    <h2>Visualisation des Temps de Travail</h2>

    <!-- Formulaire pour sélectionner un utilisateur -->
    <div>
      <label for="user-select">Sélectionnez un utilisateur:</label>
      <select v-model="selectedUserId" @change="fetchWorkingTimes">
        <option v-for="user in users" :key="user.id" :value="user.id">
          {{ user.username }}
        </option>
      </select>
    </div>

    <!-- Choix de la visualisation (chart ou calendrier) -->
    <div>
      <label>Mode de visualisation:</label>
      <input type="radio" id="chart" value="chart" v-model="viewMode" />
      <label for="chart">Graphique</label>
      <input type="radio" id="calendar" value="calendar" v-model="viewMode" />
      <label for="calendar">Calendrier</label>
    </div>

    <!-- Affichage en fonction du mode sélectionné -->
    <div v-if="viewMode === 'chart'">
      <line-chart :data="chartData" />
    </div>
    <div v-else-if="viewMode === 'calendar'">
      <vue-datepicker v-model="selectedDate" :events="calendarEvents" />
    </div>
  </div>
</template>

<script>
import LineChart from './LineChart.vue'; // Composant pour le chart
import DatePicker from 'vue2-datepicker'; // Composant pour le calendrier
import 'vue2-datepicker/index.css';

const apiUrl = process.env.VUE_APP_API_URL;

export default {
  data() {
    return {
      users: [],
      selectedUserId: null,
      workingTimes: [],
      viewMode: 'chart', // Par défaut en mode chart
      chartData: null,
      calendarEvents: [],
      selectedDate: new Date(),
    };
  },
  components: {
    LineChart,
    DatePicker,
  },
  methods: {
    async fetchUsers() {
      try {
        const response = await fetch(`${apiUrl}/users`);
        this.users = await response.json();
      } catch (error) {
        console.error('Erreur lors de la récupération des utilisateurs:', error);
      }
    },
    async fetchWorkingTimes() {
      if (!this.selectedUserId) return;

      try {
        const response = await fetch(`${apiUrl}/workingtimes?userID=${this.selectedUserId}`);
        this.workingTimes = await response.json();

        this.generateChartData();
        this.generateCalendarEvents();
      } catch (error) {
        console.error('Erreur lors de la récupération des heures de travail:', error);
      }
    },
    generateChartData() {
      const labels = this.workingTimes.map(workingtime => new Date(workingtime.start).toLocaleDateString());
      const data = this.workingTimes.map(workingtime => {
        const start = new Date(workingtime.start);
        const end = new Date(workingtime.end);
        return (end - start) / (1000 * 60 * 60); // Conversion en heures
      });

      this.chartData = {
        labels,
        datasets: [
          {
            label: 'Heures travaillées',
            data,
            fill: false,
            borderColor: '#42b983',
          },
        ],
      };
    },
    generateCalendarEvents() {
      this.calendarEvents = this.workingTimes.map(workingtime => ({
        start: new Date(workingtime.start),
        end: new Date(workingtime.end),
        title: `Heures travaillées: ${new Date(workingtime.end) - new Date(workingtime.start)}`,
      }));
    },
  },
  mounted() {
    this.fetchUsers();
  },
};
</script>

<style>
.chart-manager {
  margin-top: 20px;
  padding: 10px;
  border: 1px solid #ccc;
  border-radius: 5px;
}
</style>
