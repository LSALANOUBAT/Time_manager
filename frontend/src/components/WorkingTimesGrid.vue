<template>
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
</template>

<script>
import { Grid, h } from "gridjs";
import "gridjs/dist/theme/mermaid.css";

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
          "Start",
          "End",
          "Hours Worked",
          {
            name: "Actions",
            formatter: (cell, row) => {
              return h("div", { className: "action-buttons" }, [
                h("button", {
                  className: "button button-edit",
                  onClick: () => this.openEditModal(row.cells[0].data),
                }, "Edit"),
                h("button", {
                  className: "button button-delete",
                  onClick: () => this.deleteWorkingTime(row.cells[0].data),
                }, "Delete"),
              ]);
            },
          },
        ],
        data: this.workingTimes.map((wt) => [
          wt.id,
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
          start: new Date(workingTime.start).toISOString().slice(0, 16), // Format pour input datetime-local
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
      return toast.present();
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
  background-color: #6c757d;
}
</style>
