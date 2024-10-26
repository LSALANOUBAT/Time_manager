<template>
  <div class="chart-manager">
    <h3>Working Time Chart (Day vs Night)</h3>

    <div v-if="loading">Loading chart data...</div>
    <div v-else-if="errorMessage" class="error-message">
      <p>Error: {{ errorMessage }}</p>
    </div>
    <div v-else>
      <Line :data="chartData" :options="chartOptions" />
    </div>
  </div>
</template>

<script>
import { defineComponent, ref, watch } from 'vue';
import { Line } from 'vue-chartjs';
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  LineElement,
  PointElement,
  CategoryScale,
  LinearScale
} from 'chart.js';

// Enregistrer les composants nécessaires de Chart.js
ChartJS.register(
  Title,
  Tooltip,
  Legend,
  LineElement,
  PointElement,
  CategoryScale,
  LinearScale
);

export default defineComponent({
  name: 'ChartManager',
  components: {
    Line,
  },
  props: {
    selectedUserId: {
      type: [Number, String],
      required: true,
    },
  },
  setup(props) {
    const chartData = ref(null); // Initialiser comme null
    const chartOptions = ref({});
    const loading = ref(true);
    const errorMessage = ref(null);

    const apiUrl = process.env.VUE_APP_API_URL;

    // Fonction pour calculer la durée des heures de jour
    const calculateDayNightDuration = (start, end) => {
      const startTime = new Date(start);
      const endTime = new Date(end);

      let dayDuration = 0;
      let nightDuration = 0;

      const startHour = startTime.getHours();
      const endHour = endTime.getHours();

      // Définir les heures de jour entre 6h et 18h
      const dayStart = 6;
      const dayEnd = 18;

      // Boucler sur les heures travaillées pour les répartir entre jour et nuit
      for (let hour = startHour; hour !== endHour; hour = (hour + 1) % 24) {
        if (hour >= dayStart && hour < dayEnd) {
          dayDuration += 1;
        } else {
          nightDuration += 1;
        }
      }

      return {
        day: dayDuration,
        night: nightDuration,
      };
    };

    // Fonction pour transformer les données de l'API en format Chart.js
    const transformChartData = (data) => {
      if (!Array.isArray(data)) {
        errorMessage.value = 'Unexpected data format received from API.';
        return;
      }

      if (data.length === 0) {
        errorMessage.value = 'No working time data available.';
        return;
      }

      const labels = data.map((item) => new Date(item.start).toLocaleDateString());
      const dayDurations = [];
      const nightDurations = [];

      data.forEach((item) => {
        const durations = calculateDayNightDuration(item.start, item.end);
        dayDurations.push(durations.day);
        nightDurations.push(durations.night);
      });

      chartData.value = {
        labels: labels,
        datasets: [
          {
            label: 'Day Hours',
            data: dayDurations,
            borderColor: '#00b4d8', // Couleur des heures de jour
            backgroundColor: 'rgba(0, 180, 216, 0.2)',
            tension: 0.4,
            fill: true,
          },
          {
            label: 'Night Hours',
            data: nightDurations,
            borderColor: '#f94144', // Couleur des heures de nuit
            backgroundColor: 'rgba(249, 65, 68, 0.2)',
            tension: 0.4,
            fill: true,
          },
        ],
      };

      chartOptions.value = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'top',
          },
          tooltip: {
            backgroundColor: '#000',
            titleFont: { size: 14 },
            bodyFont: { size: 12 },
            padding: 10,
          },
        },
        scales: {
          y: {
            beginAtZero: true,
            grid: {
              display: false,
            },
            title: {
              display: true,
              text: 'Hours',
            },
          },
          x: {
            grid: {
              display: false,
            },
            title: {
              display: true,
              text: 'Date',
            },
          },
        },
      };
    };

    // Fonction pour récupérer les données des heures de travail via l'API
    const fetchWorkingTimeData = async () => {
      const token = localStorage.getItem('token');
      const userId = props.selectedUserId;

      if (!userId) {
        errorMessage.value = 'User ID not found. Please log in.';
        loading.value = false;
        return;
      }

      try {
        const endDate = new Date().toISOString(); // Date d'aujourd'hui
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - 30); // 30 jours avant aujourd'hui
        const startISO = startDate.toISOString();

        const response = await fetch(`${apiUrl}/workingtime/${userId}?start=${startISO}&end=${endDate}`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });

        if (!response.ok) {
          throw new Error(`Failed to fetch working time data: ${response.statusText}`);
        }

        const data = await response.json();
        transformChartData(data);
      } catch (error) {
        errorMessage.value = error.message;
      } finally {
        loading.value = false;
      }
    };

    // Observer les changements de selectedUserId pour recharger les données
    watch(
      () => props.selectedUserId,
      () => {
        loading.value = true;
        errorMessage.value = null;
        fetchWorkingTimeData();
      },
      { immediate: true }
    );

    return {
      chartData,
      chartOptions,
      loading,
      errorMessage,
    };
  },
});
</script>

<style scoped>
.chart-manager {
  width: 100%;
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
  border-radius: 12px;
}

.chart-manager h3 {
  text-align: center;
  font-size: 1.5em;
  margin-bottom: 20px;
  color: #333;
}

.chart-manager .error-message {
  color: red;
  text-align: center;
}

@media (max-width: 768px) {
  .chart-manager {
    padding: 15px;
  }

  .chart-manager h3 {
    font-size: 1.2em;
  }
}
</style>
