<!-- src/components/ClockIn.vue -->
<template>
  <div class="clock-in">
    <button @click="clockIn" :disabled="isLoading">
      {{ isLoading ? 'Clocking In...' : 'Clock In' }}
    </button>

    <div v-if="message" :class="['message', messageType]">
      {{ message }}
    </div>
  </div>
</template>

<script>
const apiUrl = process.env.VUE_APP_API_URL;

export default {
  name: 'ClockIn',
  data() {
    return {
      isLoading: false,
      message: '',
      messageType: '', // 'success' or 'error'
    };
  },
  methods: {
    async clockIn() {
      this.isLoading = true;
      this.message = '';
      this.messageType = '';

      try {
        const userId = localStorage.getItem('userId');
        const token = localStorage.getItem('token');

        const response = await fetch(`${apiUrl}/workingtime/${userId}/clock_in`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${token}`,
          },
        });

        const data = await response.json();

        if (response.ok) {
          this.message = 'Successfully clocked in!';
          this.messageType = 'success';
          this.$emit('clock-in'); // Émettre un événement pour mettre à jour les données parent
        } else {
          this.message = data.error || 'Failed to clock in.';
          this.messageType = 'error';
        }
      } catch (error) {
        this.message = 'An error occurred while clocking in.';
        this.messageType = 'error';
        console.error(error);
      } finally {
        this.isLoading = false;
      }
    },
  },
};
</script>

<style scoped>
.clock-in button {
  padding: 10px 20px;
  background-color: #4caf50;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

.clock-in button:disabled {
  background-color: #a5d6a7;
  cursor: not-allowed;
}

.message {
  margin-top: 10px;
  padding: 10px;
  border-radius: 5px;
}

.success {
  background-color: #c8e6c9;
  color: #2e7d32;
}

.error {
  background-color: #ffcdd2;
  color: #c62828;
}
</style>
