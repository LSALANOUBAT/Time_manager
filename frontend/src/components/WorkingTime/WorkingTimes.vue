<template>
  <div class="working-times">
    <h2>Working Times</h2>
    <input v-model="userId" placeholder="Enter User ID" @input="getWorkingTimes" />
    <ul>
      <li v-for="time in workingTimes" :key="time.id">{{ time.start }} - {{ time.end }}</li>
    </ul>

    <div v-if="errorMessage" class="error-message">
      <p>Error: {{ errorMessage }}</p>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      userId: '',
      workingTimes: [],
      errorMessage: null,
    };
  },
  methods: {
    async getWorkingTimes() {
      const apiUrl = process.env.VUE_APP_API_URL;

      if (!this.userId) {
        this.errorMessage = 'Please enter a valid User ID';
        this.workingTimes = [];
        return;
      }

      try {
        const response = await fetch(`${apiUrl}/workingtime/${this.userId}`);
        if (!response.ok) {
          throw new Error(`Server error: ${response.status}`);
        }

        const data = await response.json();
        this.workingTimes = data;
        this.errorMessage = null; // Clear error message if request is successful
      } catch (error) {
        console.error('Failed to fetch working times:', error);
        this.errorMessage = 'Failed to fetch working times. Please try again.';
        this.workingTimes = [];
      }
    },
  },
  mounted() {
    const userId = localStorage.getItem('userId'); // Get userId from local storage after login
    if (userId) {
      this.userId = userId;
      this.getWorkingTimes();
    } else {
      this.errorMessage = 'Please log in to view your working times.';
    }
  },
};
</script>

<style scoped>
.working-times {
  margin: 20px;
}

.error-message {
  color: red;
  margin-top: 10px;
}
</style>
