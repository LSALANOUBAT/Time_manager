<template>
  <div class="working-time">
    <h2>Manage Working Time</h2>
    <form @submit.prevent="createWorkingTime">
      <label for="userId">User ID:</label>
      <input
          type="text"
          v-model="userId"
          id="userId"
          placeholder="User ID"
          required
          readonly
      />

      <label for="start">Start Time:</label>
      <input
          type="datetime-local"
          v-model="start"
          id="start"
          placeholder="Start Time"
          required
      />

      <label for="end">End Time:</label>
      <input
          type="datetime-local"
          v-model="end"
          id="end"
          placeholder="End Time"
          required
      />

      <button type="submit">Create Working Time</button>
    </form>

    <button @click="updateWorkingTime">Update Working Time</button>
    <button @click="deleteWorkingTime">Delete Working Time</button>

    <!-- Error message -->
    <div v-if="errorMessage" class="error-message">
      <p>Error: {{ errorMessage }}</p>
    </div>
  </div>
</template>

<script>
const apiUrl = process.env.VUE_APP_API_URL;

export default {
  data() {
    return {
      userId: null,
      workingTimeId: null, // Set this when you want to update or delete
      start: '',
      end: '',
      errorMessage: null,
    };
  },
  mounted() {
    this.userId = localStorage.getItem('userId'); // Auto-fill the user ID from local storage
  },
  methods: {
    formatToISOString(dateTime) {
      if (dateTime) {
        return new Date(dateTime).toISOString();
      }
      return null;
    },
    async createWorkingTime() {
      if (!this.userId) {
        this.errorMessage = "User ID is required to create working time";
        return;
      }

      const startISO = this.formatToISOString(this.start);
      const endISO = this.formatToISOString(this.end);

      if (!startISO || !endISO) {
        this.errorMessage = "Start and End times are required";
        return;
      }

      try {
        const response = await fetch(`${apiUrl}/workingtime/${this.userId}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${localStorage.getItem('token')}`, // Include JWT for authentication
          },
          body: JSON.stringify({
            workingtime: {
              start: startISO,
              end: endISO,
            },
          }),
        });

        if (!response.ok) {
          throw new Error(`Server error: ${response.status}`);
        }

        const data = await response.json();
        console.log('Working time created:', data);
        this.workingTimeId = data.id; // Save working time ID after creation
        this.errorMessage = null; // Clear error message
      } catch (error) {
        this.errorMessage = 'Failed to create working time. Please try again.';
        console.error(error);
      }
    },
    async updateWorkingTime() {
      if (!this.workingTimeId) {
        this.errorMessage = "Working Time ID is required to update working time";
        return;
      }

      const startISO = this.formatToISOString(this.start);
      const endISO = this.formatToISOString(this.end);

      try {
        const response = await fetch(`${apiUrl}/workingtime/${this.workingTimeId}`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${localStorage.getItem('token')}`, // Include JWT for authentication
          },
          body: JSON.stringify({
            workingtime: {
              start: startISO,
              end: endISO,
            },
          }),
        });

        if (!response.ok) {
          throw new Error(`Server error: ${response.status}`);
        }

        const data = await response.json();
        console.log('Working time updated:', data);
        this.errorMessage = null; // Clear error message
      } catch (error) {
        this.errorMessage = 'Failed to update working time. Please try again.';
        console.error(error);
      }
    },
    async deleteWorkingTime() {
      if (!this.workingTimeId) {
        this.errorMessage = "Working Time ID is required to delete working time";
        return;
      }

      try {
        const response = await fetch(`${apiUrl}/workingtime/${this.workingTimeId}`, {
          method: 'DELETE',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${localStorage.getItem('token')}`, // Include JWT for authentication
          },
        });

        if (!response.ok) {
          throw new Error(`Server error: ${response.status}`);
        }

        console.log('Working time deleted');
        this.errorMessage = null; // Clear error message
        this.workingTimeId = null; // Clear workingTimeId after deletion
      } catch (error) {
        this.errorMessage = 'Failed to delete working time. Please try again.';
        console.error(error);
      }
    },
  },
};
</script>

<style scoped>
.working-time {
  margin: 20px;
}

.error-message {
  color: red;
  margin-top: 10px;
}
</style>
