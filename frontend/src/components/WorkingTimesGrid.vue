<template>
  <div ref="wrapper" class="grid-wrapper"></div>

  <!-- Modal for displaying working time details -->
  <div v-if="showDetailsModal" class="modal-overlay" @click.self="closeDetailsModal">
    <div class="modal-content">
      <h3>Working Times for {{ activeUserName }}</h3>
      <ul class="workingtime-list">
        <li v-for="wt in workingTimes" :key="wt.id">
          Start: {{ wt.start }} | End: {{ wt.end }} | Hours: {{ wt.hours_worked }}
          <button class="button button-delete-member" @click="deleteWorkingTime(wt.id)">Remove</button>
        </li>
      </ul>
      <button class="button button-close" @click="closeDetailsModal">Close</button>
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
      showDetailsModal: false,
      activeUserName: "",
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
              return h("div", {className: "action-buttons"}, [
                h("button", {
                  className: "button button-edit",
                  onClick: () => this.$emit("editWorkingTime", row.cells[0].data),
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

    async deleteWorkingTime(id) {
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/workingtime/${id}`, {
          method: "DELETE",
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
        });

        if (!response.ok) throw new Error("Failed to delete working time");

        // Remove the working time from local data
        this.$emit("removeWorkingTime", id);
      } catch (error) {
        console.error("Error deleting working time:", error);
      }
    },

    closeDetailsModal() {
      this.showDetailsModal = false;
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

.workingtime-list {
  list-style-type: none;
  padding: 0;
}

.workingtime-list li {
  margin: 10px 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style>
