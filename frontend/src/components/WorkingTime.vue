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
  </div>
</template>

<script>
export default {
  data() {
    return {
      userId: null,
      workingTimeId: null,
      start: '',
      end: '',
    };
  },
  methods: {
    formatToISOString(dateTime) {
      return new Date(dateTime).toISOString();
    },
    async createWorkingTime() {
      if (!this.userId) {
        console.error("User ID is required to create working time");
        return;
      }
      
      const startISO = this.formatToISOString(this.start);
      const endISO = this.formatToISOString(this.end);
      
      const response = await fetch(`http://localhost:4000/api/workingtime/${this.userId}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          workingtime: {
            user_id: this.userId,
            start: startISO,
            end: endISO
          }
        })
      });
      
      const data = await response.json();
      console.log('Working time created:', data);
    },
    async updateWorkingTime() {
      if (!this.userId || !this.workingTimeId) {
        console.error("User ID and Working Time ID are required to update working time");
        return;
      }
      
      const startISO = this.formatToISOString(this.start);
      const endISO = this.formatToISOString(this.end);
      
      const response = await fetch(`http://localhost:4000/api/workingtime/${this.workingTimeId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          workingtime: {
            user_id: this.userId,
            start: startISO,
            end: endISO
          }
        })
      });
      
      const data = await response.json();
      console.log('Working time updated:', data);
    },
    async deleteWorkingTime() {
      if (!this.userId || !this.workingTimeId) {
        console.error("User ID and Working Time ID are required to delete working time");
        return;
      }

      const response = await fetch(`http://localhost:4000/api/workingtime/${this.userId}/${this.workingTimeId}`, {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' }
      });
      
      const data = await response.json();
      console.log('Working time deleted:', data);
    }
  }
};
</script>

