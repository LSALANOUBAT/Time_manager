<template>
  <div class="clock-manager">
    <h2>Clock Manager</h2>
    <p class="status">Status: <span :class="clockIn ? 'in' : 'out'">{{ clockIn ? 'Clocked In' : 'Clocked Out' }}</span></p>
    
    <button @click="clock" :class="clockIn ? 'btn-out' : 'btn-in'">
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

    this.clockIn = !this.clockIn; // Update the local clock status
    this.errorMessage = null; // Clear error message if successful
    this.$emit('clock-changed'); // Emit an event to inform parent component
  } catch (error) {
    this.errorMessage = 'Failed to change clock status. Please try again.';
  }
}

  },
};
</script>

<style scoped>
.clock-manager {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  max-width: 400px;
  margin: 0 auto;
  background-color: #f9f9f9;
  border-radius: 12px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
}

h2 {
  font-size: 1.5em;
  margin-bottom: 20px;
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
  padding: 15px 30px;
  font-size: 1.2em;
  border-radius: 25px;
  border: none;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

.btn-in {
  background-color: #38a169; /* Green button for clocking in */
  color: white;
}

.btn-in:hover {
  background-color: #2f855a;
}

.btn-out {
  background-color: #e53e3e; /* Red button for clocking out */
  color: white;
}

.btn-out:hover {
  background-color: #c53030;
}

.error-message {
  color: red;
  margin-top: 20px;
  text-align: center;
}

@media (max-width: 768px) {
  .clock-manager {
    padding: 15px;
  }

  h2 {
    font-size: 1.2em;
  }

  button {
    padding: 12px 24px;
    font-size: 1em;
  }
}
</style>
