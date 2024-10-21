<!-- src/components/ChartManager.vue -->
<template>
  <div class="chart-manager">
    <h3>Working Time Chart</h3>

    <div v-if="loading">Loading chart data...</div>
    <div v-else-if="errorMessage" class="error-message">
      <p>Error: {{ errorMessage }}</p>
    </div>
    <div v-else>
      <!-- Debug: Afficher les données du graphique -->
      <!-- <pre>{{ chartData }}</pre> -->
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

    // Fonction pour calculer la durée en heures entre deux dates
    const calculateDuration = (start, end) => {
      const startTime = new Date(start);
      const endTime = new Date(end);
      const duration = (endTime - startTime) / (1000 * 60 * 60); // Heures
      return parseFloat(duration.toFixed(2)); // Nombre avec deux décimales
    };

    // Fonction pour transformer les données de l'API en format Chart.js
    const transformChartData = (data) => {
      console.log('Raw data from API:', data); // Log des données brutes

      if (!Array.isArray(data)) {
        errorMessage.value = 'Unexpected data format received from API.';
        return;
      }

      if (data.length === 0) {
        errorMessage.value = 'No working time data available.';
        return;
      }

      const labels = data.map((item) => new Date(item.start).toLocaleDateString());
      const durations = data.map((item) => calculateDuration(item.start, item.end));

      console.log('Labels:', labels);
      console.log('Durations:', durations);

      chartData.value = {
        labels: labels,
        datasets: [
          {
            label: 'Working Time (Hours)',
            data: durations,
            borderColor: 'rgba(75, 192, 192, 1)',
            backgroundColor: 'rgba(75, 192, 192, 0.2)',
            fill: true,
            tension: 0.4,
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
          title: {
            display: true,
            text: 'Working Time Over Time',
          },
        },
        scales: {
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: 'Hours',
            },
          },
          x: {
            title: {
              display: true,
              text: 'Date',
            },
          },
        },
      };

      console.log('chartData:', chartData.value);
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
        // Définir une plage de dates (par exemple, les 30 derniers jours)
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
}

.chart-manager h3 {
  text-align: center;
  margin-bottom: 20px;
}

.chart-manager .error-message {
  color: red;
  text-align: center;
}
</style>
