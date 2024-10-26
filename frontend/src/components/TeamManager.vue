<template>
  <div class="team-manager">
    <h2>Team Management</h2>

    <!-- Form to create or update a team -->
    <form @submit.prevent="submitTeam" class="team-form">
      <h3>{{ editingTeam ? 'Edit Team' : 'Create New Team' }}</h3>
      <input v-model="teamData.name" placeholder="Team Name" required />
      <button type="submit" :class="editingTeam ? 'button button-update' : 'button button-create'">
        {{ editingTeam ? 'Update Team' : 'Create Team' }}
      </button>
    </form>

    <!-- Display list of teams using TeamGridTable -->
    <h3>Teams</h3>
    <TeamGridTable :teams="teams" @editTeam="setEditingTeam" @deleteTeam="deleteTeam" />

    <!-- Form to assign a user to a team -->
    <div class="user-assignment">
      <h3>Assign Employee to Team</h3>
      <form @submit.prevent="assignUserToTeam">
        <select v-model="userAssignment.userId" required>
          <option disabled value="">Select User</option>
          <!-- Display user name or username -->
          <option v-for="user in users" :key="user.id" :value="user.id">
            {{ user.id }} - {{ user.name || user.username }}
          </option>
        </select>

        <select v-model="userAssignment.teamId" required>
          <option disabled value="">Select Team</option>
          <option v-for="team in teams" :key="team.id" :value="team.id">
            {{ team.id }} - {{ team.name }}
          </option>
        </select>

        <button type="submit" class="assign-button">Assign to Team</button>
      </form>
    </div>
  </div>
</template>

<script>
import { toastController } from '@ionic/vue';
import TeamGridTable from './TeamGridTable.vue';

export default {
  name: "TeamManager",
  components: {
    TeamGridTable,
  },
  data() {
    return {
      teams: [],
      users: [],
      teamData: { name: "" },
      editingTeam: null,
      userAssignment: { teamId: null, userId: null },
    };
  },
  methods: {
    async fetchTeams() {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/teams`, {
          headers: {
            Authorization: `Bearer ${localStorage.getItem('token')}`
          }
        });
        if (!response.ok) throw new Error('Failed to fetch teams');
        this.teams = (await response.json()).teams;
      } catch (error) {
        this.showToast("Error fetching teams: " + error.message, "danger");
      }
    },

    async fetchUsers() {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/users`, {
          headers: {
            Authorization: `Bearer ${localStorage.getItem('token')}`
          }
        });
        if (!response.ok) throw new Error('Failed to fetch users');
        this.users = await response.json();
      } catch (error) {
        this.showToast("Error fetching users: " + error.message, "danger");
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
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${localStorage.getItem('token')}`
          },
          body: JSON.stringify({ team: this.teamData }),
        });

        if (response.ok) {
          this.showToast(`Team ${this.editingTeam ? "updated" : "created"} successfully.`, "success");
          this.fetchTeams(); // Refresh the list of teams
          this.teamData.name = "";
          this.editingTeam = null;
        } else throw new Error("Failed to submit team");
      } catch (error) {
        this.showToast("Error submitting team: " + error.message, "danger");
      }
    },

    setEditingTeam(teamId) {
      const team = this.teams.find((team) => team.id === teamId);
      if (team) {
        this.editingTeam = team;
        this.teamData.name = team.name;
      }
    },

    async deleteTeam(teamId) {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/teams/${teamId}`, {
          method: "DELETE",
          headers: {
            Authorization: `Bearer ${localStorage.getItem('token')}`
          }
        });

        if (response.ok) {
          this.showToast("Team deleted successfully.", "success");
          this.fetchTeams();
        } else throw new Error("Failed to delete team");
      } catch (error) {
        this.showToast("Error deleting team: " + error.message, "danger");
      }
    },

    async assignUserToTeam() {
      const { teamId, userId } = this.userAssignment;

      // Log the current teamId and userId to verify they're set
      console.log("Assigning User to Team:", { teamId, userId });

      if (!teamId || !userId) {
        this.showToast("Please select both a user and a team.", "warning");
        return;
      }

      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/team_members/${userId}/team/${teamId}`, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${localStorage.getItem('token')}`,
            "Content-Type": "application/json",
          },
        });

        // Check if the response was successful
        if (response.ok) {
          this.showToast("User assigned to team successfully.", "success");
          this.userAssignment.teamId = null;
          this.userAssignment.userId = null;
          this.fetchTeams(); // Optionally refresh teams to reflect new assignment
        } else {
          const errorData = await response.json();
          console.error("API Error:", errorData);
          throw new Error(errorData.message || "Failed to assign user to team");
        }
      } catch (error) {
        this.showToast("Error assigning user to team: " + error.message, "danger");
      }
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
    this.fetchUsers();
  },
};
</script>

<style scoped>
.team-manager {
  padding: 20px;
}
.team-form, .user-assignment {
  background-color: #fff;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  margin-bottom: 20px;
}
.user-assignment select {
  margin-right: 10px;
  padding: 8px;
  font-size: 1em;
  border-radius: 4px;
  border: 1px solid #ddd;
}
.assign-button {
  background-color: #007bff;
  color: white;
  padding: 8px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}
.assign-button:hover {
  background-color: #0056b3;
}
</style>
