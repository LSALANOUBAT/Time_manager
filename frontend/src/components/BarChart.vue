<!-- src/components/BarChart.vue -->
<template>
  <canvas ref="canvas"></canvas>
</template>

<script>
import { defineComponent, ref, watch, onMounted, onBeforeUnmount } from 'vue';
import {
  Chart,
  BarController,
  BarElement,
  CategoryScale,
  LinearScale,
  Title,
  Tooltip,
  Legend
} from 'chart.js';

export default defineComponent({
  name: 'BarChart',
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
        BarController,
        BarElement,
        CategoryScale,
        LinearScale,
        Title,
        Tooltip,
        Legend
    );

    const createChart = () => {
      if (canvas.value) {
        chartInstance = new Chart(canvas.value, {
          type: 'bar',
          data: props.chartData,
          options: props.chartOptions
        });
      }
    };

    const updateChart = () => {
      if (chartInstance) {
        chartInstance.data = props.chartData;
        chartInstance.options = props.chartOptions;
        chartInstance.update();
      }
    };

    watch(
        () => props.chartData,
        () => {
          updateChart();
        },
        { deep: true }
    );

    watch(
        () => props.chartOptions,
        () => {
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
