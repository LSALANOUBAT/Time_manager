<template>
  <div class="clock-in-out">
    <h3>Manage Your Working Time</h3>
    <div class="clock-button">
      <button
          v-if="!hasActiveSession"
          @click="clockIn"
          class="clock-in-button"
      >
        Clock In
      </button>
      <button
          v-else
          @click="clockOut"
          class="clock-out-button"
      >
        Clock Out
      </button>
    </div>
    <p v-if="message" :class="messageType">{{ message }}</p>
  </div>
</template>

<script>
export default {
  name: 'ClockInOut',
  props: {
    userId: {
      type: String,
      required: true,
    },
    token: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      hasActiveSession: false,
      message: '',
      messageType: '',
    };
  },
  methods: {
    async checkActiveSession() {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/workingtime/${this.userId}`, {
          headers: { Authorization: `Bearer ${this.token}` },
        });
        if (!response.ok) throw new Error('Failed to fetch working times');
        const workingTimes = await response.json();
        const latestWorkingTime = workingTimes.sort((a, b) => new Date(b.start) - new Date(a.start))[0];
        this.hasActiveSession = latestWorkingTime && !latestWorkingTime.end;
      } catch (error) {
        this.setMessage('Error checking active session: ' + error.message, 'error');
      }
    },
    async clockIn() {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/workingtime/${this.userId}/clock_in`, {
          method: 'POST',
          headers: { Authorization: `Bearer ${this.token}` },
        });
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.error || 'Failed to clock in');
        }
        this.setMessage('Successfully clocked in.', 'success');
        this.hasActiveSession = true;
        this.$emit('session-updated');
      } catch (error) {
        this.setMessage('Error clocking in: ' + error.message, 'error');
      }
    },
    async clockOut() {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/workingtime/${this.userId}/clock_out`, {
          method: 'POST',
          headers: { Authorization: `Bearer ${this.token}` },
        });
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.error || 'Failed to clock out');
        }
        this.setMessage('Successfully clocked out.', 'success');
        this.hasActiveSession = false;
        this.$emit('session-updated');
      } catch (error) {
        this.setMessage('Error clocking out: ' + error.message, 'error');
      }
    },
    setMessage(text, type) {
      this.message = text;
      this.messageType = type;
    },
  },
  mounted() {
    this.checkActiveSession();
  },
};
</script>

<style scoped>
.clock-in-out {
  text-align: center;
  margin-bottom: 20px;
}

.clock-button button {
  padding: 10px 20px;
  font-size: 1.1em;
  cursor: pointer;
  border: none;
  border-radius: 5px;
}

.clock-in-button {
  background-color: #28a745;
  color: white;
}

.clock-out-button {
  background-color: #dc3545;
  color: white;
}

.message {
  margin-top: 15px;
}

.success {
  color: green;
}

.error {
  color: red;
}
</style>
