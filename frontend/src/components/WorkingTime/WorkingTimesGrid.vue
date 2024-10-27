<template>
  <div>
    <div ref="wrapper" class="grid-wrapper"></div>

    <!-- Modal pour la modification du working time -->
    <div v-if="showEditModal" class="modal-overlay" @click.self="closeEditModal">
      <div class="modal-content">
        <h3>Modifier le Working Time</h3>
        <form @submit.prevent="updateWorkingTime">
          <label for="start">Start:</label>
          <input type="datetime-local" v-model="editForm.start" required />

          <label for="end">End:</label>
          <input type="datetime-local" v-model="editForm.end" required />

          <div class="modal-actions">
            <button type="submit" class="button button-save">Save</button>
            <button type="button" class="button button-cancel" @click="closeEditModal">Cancel</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Formulaire pour créer un nouveau working time -->
    <div class="create-form">
      <h3>Créer un nouveau Working Time</h3>
      <form @submit.prevent="createWorkingTime">
        <label for="user_id">User ID:</label>
        <input type="number" v-model="createForm.user_id" placeholder="User ID" required />

        <label for="start">Start:</label>
        <input type="datetime-local" v-model="createForm.start" required />

        <label for="end">End:</label>
        <input type="datetime-local" v-model="createForm.end" required />

        <button type="submit" class="button button-create">Create Working Time</button>
      </form>
    </div>
  </div>
</template>

<script>
import { Grid, h } from "gridjs";
import "gridjs/dist/theme/mermaid.css";
import { toastController } from "@ionic/vue";

export default {
  name: "WorkingTimesGrid",
  props: {
    workingTimes: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      showEditModal: false,
      editForm: {
        id: null,
        start: "",
        end: "",
      },
      createForm: {
        user_id: "",
        start: "",
        end: "",
      },
    };
  },
  mounted() {
    this.renderGrid();
  },
  watch: {
    workingTimes() {
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
          "User ID",
          "Username",
          "Start",
          "End",
          "Hours Worked",
          {
            name: "Actions",
            formatter: (cell, row) => {
              return h("div", { className: "action-buttons" }, [
                h(
                    "button",
                    {
                      className: "button button-edit",
                      onClick: () => {
                        this.openEditModal(row.cells[0].data);
                      },
                    },
                    "Edit"
                ),
                h(
                    "button",
                    {
                      className: "button button-delete",
                      onClick: () => this.deleteWorkingTime(row.cells[0].data),
                    },
                    "Delete"
                ),
              ]);
            },
          },
        ],
        data: this.workingTimes.map((wt) => [
          wt.id,
          wt.user_id,
          wt.username,
          new Date(wt.start).toLocaleString(),
          new Date(wt.end).toLocaleString(),
          wt.hours_worked,
        ]),
        pagination: {
          enabled: true,
          limit: 5,
        },
        search: true,
        sort: true,
        language: {
          search: { placeholder: "Search..." },
          pagination: {
            previous: "Previous",
            next: "Next",
            showing: "Showing",
            results: () => "rows",
          },
        },
      }).render(this.$refs.wrapper);
    },

    openEditModal(id) {
      const workingTime = this.workingTimes.find((wt) => wt.id === id);
      if (workingTime) {
        this.editForm = {
          id: workingTime.id,
          start: new Date(workingTime.start).toISOString().slice(0, 16),
          end: new Date(workingTime.end).toISOString().slice(0, 16),
        };
        this.showEditModal = true;
      }
    },

    async updateWorkingTime() {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/workingtime/${this.editForm.id}`, {
          method: "PUT",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
          body: JSON.stringify({
            workingtime: {
              start: new Date(this.editForm.start).toISOString(),
              end: new Date(this.editForm.end).toISOString(),
            },
          }),
        });

        if (!response.ok) throw new Error("Failed to update working time");

        this.$emit("workingTimeUpdated", this.editForm);
        this.showToast("Working time updated successfully!", "success");
        this.closeEditModal();
      } catch (error) {
        console.error("Error updating working time:", error);
        this.showToast("Error updating working time: " + error.message, "danger");
      }
    },

    async createWorkingTime() {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/workingtime/${this.createForm.user_id}`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
          body: JSON.stringify({
            workingtime: {
              start: new Date(this.createForm.start).toISOString(),
              end: new Date(this.createForm.end).toISOString(),
            },
          }),
        });

        if (!response.ok) throw new Error("Failed to create working time");

        this.$emit("workingTimeCreated");
        this.showToast("Working time created successfully!", "success");

        this.createForm.user_id = "";
        this.createForm.start = "";
        this.createForm.end = "";
      } catch (error) {
        console.error("Error creating working time:", error);
        this.showToast("Error creating working time: " + error.message, "danger");
      }
    },

    closeEditModal() {
      this.showEditModal = false;
      this.editForm = { id: null, start: "", end: "" };
    },

    async deleteWorkingTime(id) {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/workingtime/${id}`, {
          method: "DELETE",
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
        });

        if (!response.ok) throw new Error("Failed to delete working time");

        this.$emit("removeWorkingTime", id);
        this.showToast("Working time deleted successfully!", "success");
      } catch (error) {
        console.error("Error deleting working time:", error);
        this.showToast("Error deleting working time: " + error.message, "danger");
      }
    },

    async showToast(message, color) {
      const toast = await toastController.create({
        message,
        duration: 3000,
        color,
        position: "top",
      });
      await toast.present();
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

.button-create {
  background-color: #007bff;
}

.button-create:hover {
  background-color: #0056b3;
}

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
  max-width: 400px;
  width: 90%;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

.button-save {
  background-color: #4caf50;
}

.button-cancel {
  background-color: #f44336;
}

.create-form {
  margin-top: 20px;
  padding: 15px;
  background-color: #f9f9f9;
  border: 1px solid #ddd;
  border-radius: 8px;
}

.create-form h3 {
  margin-bottom: 15px;
}

.create-form label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
}

.create-form input {
  width: 100%;
  padding: 8px;
  margin-bottom: 10px;
  border-radius: 4px;
  border: 1px solid #ccc;
}

.button-create {
  display: block;
  width: 100%;
  padding: 10px;
  font-weight: bold;
}
</style>
