<template>
  <div class="clock-manager">
    <h2>Clock Manager</h2>
    <input v-model="userId" placeholder="Enter User ID" />
    <p>Status: {{ clockIn ? 'Clocked In' : 'Clocked Out' }}</p>
    <button @click="clock">{{ clockIn ? 'Clock Out' : 'Clock In' }}</button>

    <div v-if="errorMessage" class="error-message">
      <p>Error: {{ errorMessage }}</p>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      userId: '', // User ID associated with the clock action
      clockIn: false, // Current clock status
      errorMessage: null, // Error message for any issues
    };
  },
  methods: {
    async clock() {
      if (!this.userId) {
        this.errorMessage = 'Please enter a valid User ID';
        return;
      }

      try {
        const response = await fetch(`http://localhost:4000/api/clocks/${this.userId}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            clock: {
              status: !this.clockIn, // Toggles the clock status
              time: new Date().toISOString(), // Sends the current timestamp
            },
          }),
        });

        if (!response.ok) {
          throw new Error(`Server error: ${response.status}`);
        }

        const data = await response.json();
        this.clockIn = !this.clockIn; // Update the local clock status
        console.log('Clock status changed:', data);
        this.errorMessage = null; // Clear error message if request is successful
      } catch (error) {
        console.error('Failed to change clock status:', error);
        this.errorMessage = 'Failed to change clock status. Please try again.';
      }
    },
  },
};
</script>

<style scoped>
.clock-manager {
  margin: 20px;
}

.error-message {
  color: red;
  margin-top: 10px;
}
</style>
