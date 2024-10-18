<template>
  <div>
    <h2>Statistiques du temps de travail</h2>
    <BarChart :chart-data="chartData" :options="chartOptions" />
  </div>
</template>

<script>
import { Bar } from 'vue-chartjs';
import { ref, onMounted } from 'vue';
import axios from 'axios';

export default {
  name: 'ChartManager',
  components: {
    BarChart: {
      extends: Bar,
      props: ['chartData', 'options'],
      mounted() {
        this.renderChart(this.chartData, this.options);
      },
      watch: {
        chartData(newData) {
          this.renderChart(newData, this.options);
        },
      },
    },
  },
  setup() {
    const chartData = ref(null);
    const chartOptions = ref({
      responsive: true,
      maintainAspectRatio: false,
    });

    const fetchWorkingTimes = async () => {
      try {
        // Remplace l'URL par celle de ton backend
        const response = await axios.get('/api/workingtimes');
        const data = response.data;

        // Traite les données pour le graphique
        const labels = data.map(item => item.date); // Par exemple
        const workingHours = data.map(item => item.hours);

        chartData.value = {
          labels,
          datasets: [
            {
              label: 'Heures travaillées',
              backgroundColor: '#f87979',
              data: workingHours,
            },
          ],
        };
      } catch (error) {
        console.error('Erreur lors de la récupération des temps de travail:', error);
      }
    };

    onMounted(() => {
      fetchWorkingTimes();
    });

    return {
      chartData,
      chartOptions,
    };
  },
};
</script>

<style scoped>
h2 {
  margin-bottom: 20px;
}
</style>
