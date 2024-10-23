<template>
  <div class="clock-manager">
    <h3>Clock Manager</h3>
    <p class="status">Status: <span :class="clockIn ? 'in' : 'out'">{{ clockIn ? 'Clocked In' : 'Clocked Out' }}</span></p>
    <button @click="clock" :class="clockIn ? 'btn-clock-out' : 'btn-clock-in'">
      {{ clockIn ? 'Clock Out' : 'Clock In' }}
    </button>

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
        this.errorMessage = null; // Clear error message if successful
        this.$emit('clock-changed'); // Emit an event to inform parent component
      } catch (error) {
        this.errorMessage = 'Failed to change clock status. Please try again.';
      }
    },
  },
};
</script>

<style scoped>
.clock-manager {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
  max-width: 400px;
  margin: 20px auto;
}

h3 {
  font-size: 1.5em;
  margin-bottom: 10px;
  color: #333;
}

.status {
  font-size: 1.2em;
  margin-bottom: 20px;
}

.status .in {
  color: #38a169; /* Green for clocked in */
}

.status .out {
  color: #e53e3e; /* Red for clocked out */
}

button {
  background-color: white;
  color: black;
  border-radius: 10em;
  font-size: 17px;
  font-weight: 600;
  padding: 1em 2em;
  cursor: pointer;
  transition: all 0.3s ease-in-out;
  border: 1px solid black;
  box-shadow: 0 0 0 0 black;
}

button:hover {
  transform: translateY(-4px) translateX(-2px);
  box-shadow: 2px 5px 0 0 black;
}

button:active {
  transform: translateY(2px) translateX(1px);
  box-shadow: 0 0 0 0 black;
}

.error-message {
  color: red;
  margin-top: 20px;
  text-align: center;
}

.btn-clock-in {
  background-color: #38a169; /* Green for Clock In */
  color: white;
  border: none;
}

.btn-clock-out {
  background-color: #e53e3e; /* Red for Clock Out */
  color: white;
  border: none;
}

@media (max-width: 768px) {
  .clock-manager {
    padding: 15px;
  }

  h3 {
    font-size: 1.2em;
  }

  button {
    font-size: 1em;
    padding: 10px 20px;
  }
}
</style>
