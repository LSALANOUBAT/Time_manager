<!-- src/components/ClockOut.vue -->
<template>
  <div class="clock-out">
    <button @click="clockOut" :disabled="isLoading">
      {{ isLoading ? 'Clocking Out...' : 'Clock Out' }}
    </button>

    <div v-if="message" :class="['message', messageType]">
      {{ message }}
    </div>
  </div>
</template>

<script>
const apiUrl = process.env.VUE_APP_API_URL;

export default {
  name: 'ClockOut',
  data() {
    return {
      isLoading: false,
      message: '',
      messageType: '', // 'success' or 'error'
    };
  },
  methods: {
    async clockOut() {
      this.isLoading = true;
      this.message = '';
      this.messageType = '';

      try {
        const userId = localStorage.getItem('userId');
        const token = localStorage.getItem('token');

        const response = await fetch(`${apiUrl}/workingtime/${userId}/clock_out`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${token}`,
          },
        });

        const data = await response.json();

        if (response.ok) {
          this.message = 'Successfully clocked out!';
          this.messageType = 'success';
          this.$emit('clock-out'); // Émettre un événement pour mettre à jour les données parent
        } else {
          this.message = data.error || 'Failed to clock out.';
          this.messageType = 'error';
        }
      } catch (error) {
        this.message = 'An error occurred while clocking out.';
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
.clock-out button {
  padding: 10px 20px;
  background-color: #f44336;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

.clock-out button:disabled {
  background-color: #ef9a9a;
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

