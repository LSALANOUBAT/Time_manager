<template>
  <div ref="wrapper" class="grid-wrapper"></div>
</template>

<script>
import { Grid, h } from "gridjs"; // Import Grid and h from gridjs
import "gridjs/dist/theme/mermaid.css"; // Import the Grid.js theme

export default {
  name: "GridTable",
  props: {
    users: {
      type: Array,
      required: true,
    },
  },
  mounted() {
    // Initialize the Grid.js table when the component is mounted
    this.renderGrid();
  },
  watch: {
    // Re-render the Grid.js table when the users array changes
    users() {
      this.renderGrid();
    },
  },
  methods: {
    renderGrid() {
      // Destroy the existing grid if it exists
      if (this.grid) {
        this.grid.destroy();
      }

      // Render a new grid instance
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
                  className: "btn btn-primary edit-button",
                  onClick: () => this.$emit("editUser", row.cells[0].data), // Pass user ID for editing
                }, "Edit"),
                h("button", {
                  className: "btn btn-danger delete-button",
                  onClick: () => this.$emit("deleteUser", row.cells[0].data), // Pass user ID for deletion
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
        search: true, // Enable the search bar
        sort: true,   // Enable column sorting
        language: {
          search: {
            placeholder: 'Search...',
          },
          pagination: {
            previous: 'Previous',
            next: 'Next',
            showing: 'Showing',
            results: () => 'rows',
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

.action-buttons {
  display: flex;
  justify-content: flex-start; /* Align buttons to the start */
  gap: 10px; /* Space between buttons */
}

.edit-button, .delete-button {
  padding: 5px 10px; /* Padding for buttons */
  border: none; /* Remove border */
  border-radius: 5px; /* Rounded corners */
  cursor: pointer; /* Pointer cursor on hover */
}

.edit-button {
  background-color: #007bff; /* Primary color for edit button */
  color: white; /* Text color for edit button */
}

.edit-button:hover {
  background-color: #0056b3; /* Darker shade on hover */
}

.delete-button {
  background-color: crimson; /* Red for delete button */
  color: white; /* Text color for delete button */
}

.delete-button:hover {
  background-color: darkred; /* Darker shade on hover */
}
</style>
