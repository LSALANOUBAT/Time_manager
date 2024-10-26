<!-- src/components/CalendarManager.vue -->
<template>
  <div class="calendar-manager">
    <h3>Working Time Calendar</h3>

    <div v-if="loading">Loading calendar data...</div>
    <div v-else-if="errorMessage" class="error-message">
      <p>Error: {{ errorMessage }}</p>
    </div>
    <div v-else>
      <FullCalendar
          :options="calendarOptions"
          @select="handleDateSelect"
      />
      <div class="summary" v-if="selectedRange">
        <h4>Summary for Selected Period:</h4>
        <p>{{ selectedRange.label }}</p>
        <p>Total Working Hours: {{ totalHours }} Hours</p>
      </div>
    </div>
  </div>
</template>

<script>
import { defineComponent, ref, watch, onMounted } from 'vue';
import FullCalendar from '@fullcalendar/vue3';
import dayGridPlugin from '@fullcalendar/daygrid';
import interactionPlugin from '@fullcalendar/interaction';

export default defineComponent({
  name: 'CalendarManager',
  components: {
    FullCalendar,
  },
  props: {
    selectedUserId: {
      type: [Number, String],
      required: true,
    },
  },
  setup(props) {
    const calendarData = ref([]);
    const loading = ref(true);
    const errorMessage = ref(null);
    const selectedRange = ref(null);
    const totalHours = ref(0);

    const apiUrl = process.env.VUE_APP_API_URL;

    // Fonction pour calculer la durée en heures entre deux dates
    const calculateDuration = (start, end) => {
      const startTime = new Date(start);
      const endTime = new Date(end);
      const duration = (endTime - startTime) / (1000 * 60 * 60); // Heures
      return parseFloat(duration.toFixed(2)); // Nombre avec deux décimales
    };

    // Fonction pour transformer les données de l'API en événements pour le calendrier
    const transformCalendarData = (data) => {
      if (!Array.isArray(data)) {
        errorMessage.value = 'Unexpected data format received from API.';
        return;
      }

      if (data.length === 0) {
        errorMessage.value = 'No working time data available.';
        return;
      }

      const events = data.map((item) => ({
        title: `Working Hours: ${calculateDuration(item.start, item.end)} Hours`,
        start: item.start,
        end: item.end,
        allDay: false,
      }));

      calendarData.value = events;
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

        const response = await fetch(
            `${apiUrl}/workingtime/${userId}?start=${startISO}&end=${endDate}`,
            {
              headers: {
                Authorization: `Bearer ${token}`,
              },
            }
        );

        if (!response.ok) {
          throw new Error(`Failed to fetch working time data: ${response.statusText}`);
        }

        const data = await response.json();
        transformCalendarData(data);
      } catch (error) {
        errorMessage.value = error.message;
      } finally {
        loading.value = false;
      }
    };

    // Fonction pour gérer la sélection de dates sur le calendrier
    const handleDateSelect = (selectInfo) => {
      const start = new Date(selectInfo.start);
      const end = new Date(selectInfo.end);

      // Filtrer les événements qui tombent dans la plage sélectionnée
      const filteredEvents = calendarData.value.filter((event) => {
        const eventStart = new Date(event.start);
        const eventEnd = new Date(event.end);
        return (
            (eventStart >= start && eventStart < end) ||
            (eventEnd > start && eventEnd <= end) ||
            (eventStart <= start && eventEnd >= end)
        );
      });

      // Calculer le total des heures
      const hours = filteredEvents.reduce((acc, event) => {
        const duration = calculateDuration(event.start, event.end);
        return acc + duration;
      }, 0);

      // Mettre à jour le résumé
      selectedRange.value = {
        start: start.toLocaleDateString(),
        end: (new Date(end.getTime() - 1)).toLocaleDateString(), // Ajuster la date de fin
        label: `${start.toLocaleDateString()} - ${(new Date(end.getTime() - 1)).toLocaleDateString()}`,
      };
      totalHours.value = hours.toFixed(2);
    };

    // Options pour FullCalendar
    const calendarOptions = ref({
      plugins: [dayGridPlugin, interactionPlugin],
      initialView: 'dayGridMonth',
      selectable: true,
      selectMirror: true,
      select: handleDateSelect,
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,dayGridWeek,dayGridDay',
      },
      events: calendarData.value,
    });

    // Watcher pour mettre à jour les événements lorsque calendarData change
    watch(
        () => calendarData.value,
        (newEvents) => {
          calendarOptions.value.events = newEvents;
        }
    );

    onMounted(() => {
      fetchWorkingTimeData();
    });

    return {
      calendarOptions,
      loading,
      errorMessage,
      selectedRange,
      totalHours,
    };
  },
});
</script>

<style scoped>
.calendar-manager {
  width: 100%;
  max-width: 900px;
  margin: 0 auto;
}

.calendar-manager h3 {
  text-align: center;
  margin-bottom: 20px;
}

.calendar-manager .error-message {
  color: red;
  text-align: center;
}

.summary {
  margin-top: 20px;
  text-align: center;
  background-color: #f3f3f3;
  padding: 15px;
  border-radius: 5px;
}
</style>
