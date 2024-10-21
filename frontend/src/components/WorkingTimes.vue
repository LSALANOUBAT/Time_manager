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
const apiUrl = process.env.VUE_APP_API_URL;

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
      if (!this.userId) {
        this.errorMessage = 'Please enter a valid User ID';
        this.workingTimes = [];
        return;
      }

      const token = localStorage.getItem('token');
      if (!token) {
        this.errorMessage = 'You must be logged in to fetch working times.';
        return;
      }

      try {
        const response = await fetch(`${apiUrl}/workingtime/${this.userId}`, {
          headers: {
            'Authorization': `Bearer ${token}`,
          },
        });

        if (!response.ok) {
          throw new Error(`Error fetching working times: ${response.status}`);
        }

        const data = await response.json();
        this.workingTimes = data;
        this.errorMessage = null; // Clear error if the request is successful
      } catch (error) {
        this.errorMessage = error.message;
        this.workingTimes = [];
      }
    },
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
