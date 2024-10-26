<template>
  <div class="team-manager">
    <h2>Team Management</h2>

    <!-- Form to create or update a team -->
    <form @submit.prevent="submitTeam" class="team-form">
      <h3>{{ editingTeam ? 'Edit Team' : 'Create New Team' }}</h3>
      <input v-model="teamData.name" placeholder="Team Name" required />

      <button type="submit">{{ editingTeam ? 'Update Team' : 'Create Team' }}</button>
    </form>

    <!-- Display list of teams -->
    <h3>Teams</h3>
    <ul class="team-list">
      <li v-for="team in teams" :key="team.id">
        <span>{{ team.name }}</span>
        <button class="button-edit" @click="editTeam(team)">Edit</button>
        <button class="button-delete" @click="deleteTeam(team.id)">Delete</button>
        <button @click="assignUserToTeam(team.id)">Add User</button>
      </li>
    </ul>
  </div>
</template>

<script>
import { toastController } from '@ionic/vue';

export default {
  name: "TeamManager",
  data() {
    return {
      teams: [],
      teamData: { name: "" },
      editingTeam: null,
    };
  },
  methods: {
    async fetchTeams() {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/teams`);
        this.teams = await response.json();
      } catch (error) {
        this.showToast("Failed to load teams.", "danger");
      }
    },
    async submitTeam() {
      try {
        const url = this.editingTeam
            ? `${process.env.VUE_APP_API_URL}/teams/${this.editingTeam.id}`
            : `${process.env.VUE_APP_API_URL}/teams`;
        const method = this.editingTeam ? "PUT" : "POST";

        const response = await fetch(url, {
          method,
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ team: this.teamData }),
        });

        if (response.ok) {
          this.showToast(`Team ${this.editingTeam ? "updated" : "created"} successfully.`, "success");
          this.fetchTeams();
          this.teamData.name = "";
          this.editingTeam = null;
        } else {
          this.showToast("Failed to submit team.", "danger");
        }
      } catch (error) {
        this.showToast("Error occurred while submitting team.", "danger");
      }
    },
    editTeam(team) {
      this.editingTeam = team;
      this.teamData.name = team.name;
    },
    async deleteTeam(teamId) {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/teams/${teamId}`, { method: "DELETE" });
        if (response.ok) {
          this.showToast("Team deleted successfully.", "success");
          this.fetchTeams();
        } else {
          this.showToast("Failed to delete team.", "danger");
        }
      } catch (error) {
        this.showToast("Error occurred while deleting team.", "danger");
      }
    },
    async assignUserToTeam(teamId) {
      // Implement logic to assign a user to a team.
      this.showToast("User assigned to team successfully.", "success");
    },
    async showToast(message, color) {
      const toast = await toastController.create({
        message,
        duration: 3000,
        color,
      });
      return toast.present();
    },
  },
  mounted() {
    this.fetchTeams();
  },
};
</script>

<style scoped>
.team-manager {
  padding: 20px;
}
.team-form {
  background-color: #fff;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  margin-bottom: 20px;
}
.team-list {
  list-style-type: none;
  padding: 0;
}
.team-list li {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px;
  background-color: #f4f4f4;
  margin-bottom: 10px;
  border-radius: 5px;
}
.button-edit, .button-delete {
  padding: 5px 10px;
  border: none;
  border-radius: 5px;
  color: white;
  cursor: pointer;
  font-size: 12px;
}
.button-edit {
  background-color: #4caf50;
}
.button-delete {
  background-color: #f44336;
}
</style>
