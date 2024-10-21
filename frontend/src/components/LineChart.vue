<!-- src/components/LineChart.vue -->
<template>
  <canvas ref="canvas"></canvas>
</template>

<script>
import { defineComponent, ref, watch, onMounted, onBeforeUnmount } from 'vue';
import {
  Chart,
  LineController,
  LineElement,
  PointElement,
  LinearScale,
  Title,
  CategoryScale,
  Tooltip,
  Legend
} from 'chart.js';

export default defineComponent({
  name: 'LineChart',
  props: {
    chartData: {
      type: Object,
      required: true
    },
    chartOptions: {
      type: Object,
      default: () => ({})
    }
  },
  setup(props) {
    const canvas = ref(null);
    let chartInstance = null;

    // Enregistrer les composants Chart.js nécessaires
    Chart.register(
        LineController,
        LineElement,
        PointElement,
        LinearScale,
        Title,
        CategoryScale,
        Tooltip,
        Legend
    );

    const createChart = () => {
      if (canvas.value) {
        chartInstance = new Chart(canvas.value, {
          type: 'line',
          data: { ...props.chartData }, // Cloner chartData
          options: { ...props.chartOptions } // Cloner chartOptions
        });
      }
    };

    const updateChart = () => {
      if (chartInstance) {
        chartInstance.data = { ...props.chartData }; // Cloner chartData
        chartInstance.options = { ...props.chartOptions }; // Cloner chartOptions
        chartInstance.update();
      }
    };

    watch(
        () => props.chartData,
        () => {
          console.log('LineChart.vue: chartData changed');
          updateChart();
        },
        { deep: true }
    );

    watch(
        () => props.chartOptions,
        () => {
          console.log('LineChart.vue: chartOptions changed');
          updateChart();
        },
        { deep: true }
    );

    onMounted(() => {
      createChart();
    });

    onBeforeUnmount(() => {
      if (chartInstance) {
        chartInstance.destroy();
      }
    });

    return { canvas };
  }
});
</script>

<style scoped>
canvas {
  max-width: 600px;
  height: 400px;
}
</style>
