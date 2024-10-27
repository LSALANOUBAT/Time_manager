<template>
  <div ref="wrapper" class="grid-wrapper"></div>
</template>

<script>
import { Grid, h } from "gridjs";
import "gridjs/dist/theme/mermaid.css";

export default {
  name: "GridTable",
  props: {
    users: {
      type: Array,
      required: true,
    },
  },
  mounted() {
    this.initializeGrid();
  },
  watch: {
    users(newData) {
      if (this.grid) {
        // Update grid data without reinitializing the entire grid
        this.grid.updateConfig({
          data: newData.map((user) => [
            user.id,
            user.username,
            user.email,
            user.role,
            new Date(user.updated_at || user.created_at).toLocaleString(),
          ]),
        }).forceRender();
      }
    },
  },
  methods: {
    initializeGrid() {
      this.grid = new Grid({
        columns: [
          "ID",
          "Username",
          "Email",
          "Role",
          "Last Modified",
          {
            name: "Actions",
            formatter: (cell, row) => {
              return h("div", { className: "action-buttons" }, [
                h("button", {
                  className: "button button-edit",
                  onClick: () => this.$emit("editUser", row.cells[0].data),
                }, "Edit"),
                h("button", {
                  className: "button button-delete",
                  onClick: () => this.$emit("deleteUser", row.cells[0].data),
                }, "Delete"),
              ]);
            },
          },
        ],
        data: this.users.map((user) => [
          user.id,
          user.username,
          user.email,
          user.role,
          new Date(user.updated_at || user.created_at).toLocaleString(),
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
  },
};
</script>

<style scoped>
.grid-wrapper {
  margin-top: 20px;
}

/* Base style for action buttons */
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

/* Hover and active effects */
.button:hover {
  transform: translateY(-2px);
}

.button:active {
  transform: translateY(0);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
}

/* Edit button style */
.button-edit {
  background-color: #4CAF50;
}

.button-edit:hover {
  background-color: #388E3C;
}

/* Delete button style */
.button-delete {
  background-color: #F44336;
}

.button-delete:hover {
  background-color: #D32F2F;
}

/* Action buttons layout */
.action-buttons {
  display: flex;
  gap: 10px;
}
</style>
