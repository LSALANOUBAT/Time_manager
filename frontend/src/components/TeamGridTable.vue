<template>
  <div ref="wrapper" class="grid-wrapper"></div>

  <!-- Modal for displaying team members -->
  <div v-if="showMembersModal" class="modal-overlay" @click.self="closeMembersModal">
    <div class="modal-content">
      <h3>Team Members of {{ activeTeamName }}</h3>
      <ul class="member-list">
        <li v-for="member in teamMembers" :key="member.id">
          {{ member.username }} ({{ member.role }})
          <button class="button button-delete-member" @click="deleteMember(member.id)">Remove</button>
        </li>
      </ul>
      <button class="button button-close" @click="closeMembersModal">Close</button>
    </div>
  </div>
</template>

<script>
import {Grid, h} from "gridjs";
import "gridjs/dist/theme/mermaid.css";

export default {
  name: "TeamGridTable",
  props: {
    teams: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      showMembersModal: false,
      teamMembers: [],
      activeTeamId: null,
      activeTeamName: "",
    };
  },
  mounted() {
    this.renderGrid();
  },
  watch: {
    teams() {
      this.renderGrid();
    },
  },
  methods: {
    renderGrid() {
      if (this.grid) {
        this.grid.destroy();
      }

      this.grid = new Grid({
        columns: [
          "ID",
          "Name",
          "Manager ID",
          "Created At",
          {
            name: "Actions",
            formatter: (cell, row) => {
              return h("div", {className: "action-buttons"}, [
                h("button", {
                  className: "button button-edit",
                  onClick: () => this.$emit("editTeam", row.cells[0].data),
                }, "Edit"),
                h("button", {
                  className: "button button-delete",
                  onClick: () => this.$emit("deleteTeam", row.cells[0].data),
                }, "Delete"),
                h("button", {
                  className: "button button-view-members",
                  onClick: () => this.fetchTeamMembers(row.cells[0].data, row.cells[1].data),
                }, "View Members"),
              ]);
            },
          },
        ],
        data: this.teams.map((team) => [
          team.id,
          team.name,
          team.manager_id,
          new Date(team.inserted_at).toLocaleString(),
        ]),
        pagination: {
          enabled: true,
          limit: 5,
        },
        search: true,
        sort: true,
        language: {
          search: {placeholder: "Search..."},
          pagination: {
            previous: "Previous",
            next: "Next",
            showing: "Showing",
            results: () => "rows",
          },
        },
      }).render(this.$refs.wrapper);
    },

    async fetchTeamMembers(teamId, teamName) {
      if (!teamId) {
        console.error("Error: teamId is missing.");
        return;
      }

      this.activeTeamId = teamId;
      this.activeTeamName = teamName;

      try {
        const response = await fetch(
            `${process.env.VUE_APP_API_URL}/team_members/${teamId}`, // Using teamId in URL path
            {
              headers: {
                Authorization: `Bearer ${localStorage.getItem("token")}`,
              },
            }
        );
        if (!response.ok) throw new Error("Failed to fetch team members");

        const data = await response.json();
        this.teamMembers = data.members;
        this.showMembersModal = true;
      } catch (error) {
        console.error("Error fetching team members:", error);
      }
    },

    async deleteMember(memberId) {
      if (!this.activeTeamId) {
        console.error("Error: activeTeamId is missing for deletion.");
        return;
      }

      try {
        const response = await fetch(
            `${process.env.VUE_APP_API_URL}/team_members/${memberId}/team/${this.activeTeamId}`,
            {
              method: "DELETE",
              headers: {
                Authorization: `Bearer ${localStorage.getItem("token")}`,
              },
            }
        );
        if (!response.ok) throw new Error("Failed to delete member");

        // Remove member from local list on success
        this.teamMembers = this.teamMembers.filter(
            (member) => member.id !== memberId
        );
      } catch (error) {
        console.error("Error deleting member:", error);
      }
    },

    closeMembersModal() {
      this.showMembersModal = false;
      this.teamMembers = [];
      this.activeTeamId = null;
      this.activeTeamName = "";
    },
  },
};
</script>

<style scoped>
.grid-wrapper {
  margin-top: 20px;
}

.action-buttons {
  display: flex;
  gap: 10px;
}

.button {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  color: white;
  transition: background-color 0.3s, box-shadow 0.2s, transform 0.2s;
  box-shadow: 0 3px 6px rgba(0, 0, 0, 0.2);
}

/* Button styles */
.button-edit {
  background-color: #4caf50;
}

.button-edit:hover {
  background-color: #388e3c;
}

.button-delete {
  background-color: #f44336;
}

.button-delete:hover {
  background-color: #d32f2f;
}

.button-view-members {
  background-color: #007bff;
}

.button-view-members:hover {
  background-color: #0056b3;
}

.button-delete-member {
  background-color: #ff6347;
  margin-left: 10px;
}

.button-delete-member:hover {
  background-color: #d9452a;
}

.button-close {
  margin-top: 15px;
  background-color: #6c757d;
}

.button-close:hover {
  background-color: #5a6268;
}

/* Modal styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-content {
  background: white;
  padding: 20px;
  border-radius: 8px;
  max-width: 500px;
  width: 90%;
}

.member-list {
  list-style-type: none;
  padding: 0;
}

.member-list li {
  margin: 10px 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style>
