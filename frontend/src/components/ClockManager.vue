<template>
  <div class="clock-manager">
    <h2>Clock Manager</h2>
    <p>Status: {{ clockIn ? 'Clocked In' : 'Clocked Out' }}</p>
    <button @click="clock">{{ clockIn ? 'Clock Out' : 'Clock In' }}</button>

    <div v-if="errorMessage" class="error-message">
      <p>Error: {{ errorMessage }}</p>
    </div>
  </div>
</template>

<script>
const apiUrl = process.env.VUE_APP_API_URL;

export default {
  props: ['userId'], // Accept the userId as a prop
  data() {
    return {
      clockIn: false, // Current clock status
      errorMessage: null, // Error message for any issues
    };
  },
  methods: {
    async clock() {
      if (!this.userId) {
        this.errorMessage = 'User ID is missing';
        return;
      }

      const token = localStorage.getItem('token'); // Retrieve token for authentication

      if (!token) {
        this.errorMessage = 'Missing authentication token';
        return;
      }

      try {
        const response = await fetch(`${apiUrl}/clocks/${this.userId}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${token}`, // Pass the token in the Authorization header
          },
          body: JSON.stringify({
            clock: {
              status: !this.clockIn, // Toggle the clock status
              time: new Date().toISOString(), // Current timestamp
            },
          }),
        });

        if (!response.ok) {
          throw new Error(`Server error: ${response.status}`);
        }

        const data = await response.json();
        this.clockIn = !this.clockIn; // Update the local clock status
        console.log('Clock status changed:', data);
        this.errorMessage = null; // Clear error message if successful
        this.$emit('clock-changed'); // Emit an event to inform parent component
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
