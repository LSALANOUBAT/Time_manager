<template>
  <div class="hamburger">
    <input class="checkbox" type="checkbox" v-model="isChecked" />
    <svg fill="none" viewBox="0 0 50 50" height="50" width="50">
      <path
          class="lineTop line"
          stroke-linecap="round"
          stroke-width="4"
          stroke="black"
          d="M6 11L44 11"
      ></path>
      <path
          stroke-linecap="round"
          stroke-width="4"
          stroke="black"
          d="M6 24H43"
          class="lineMid line"
      ></path>
      <path
          stroke-linecap="round"
          stroke-width="4"
          stroke="black"
          d="M6 37H43"
          class="lineBottom line"
      ></path>
    </svg>

    <!-- Menu Dropdown -->
    <div v-if="isChecked" class="menu-dropdown">
      <button @click="showChangePasswordModal" class="menu-btn">Change Password</button>
      <button @click="logout" class="menu-btn">Logout</button>
    </div>

    <!-- Change Password Modal -->
    <div v-if="showModal" class="modal-overlay" @click.self="closeModal">
      <div class="modal-content">
        <h3>Update Password</h3>
        <input v-model="newPassword" type="password" placeholder="Enter new password" />
        <button @click="updatePassword" class="button-edit">Update Password</button>
        <button @click="closeModal" class="button-cancel">Cancel</button>
      </div>
    </div>
  </div>
</template>

<script>
import { toastController } from "@ionic/vue";
import { defineCustomElements } from "@ionic/core/loader";

export default {
  data() {
    return {
      isChecked: false,
      showModal: false,
      newPassword: "",
    };
  },
  methods: {
    showChangePasswordModal() {
      this.showModal = true;
      this.isChecked = false;
    },
    async updatePassword() {
      const token = localStorage.getItem("token");
      try {
        const response = await fetch(`${process.env.VUE_APP_API_URL}/update_password`, {
          method: "PUT",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({password: this.newPassword}),
        });

        if (response.ok) {
          this.showToast("Password updated successfully.", "success");
          this.closeModal();
        } else {
          this.showToast("Failed to update password.", "danger");
        }
      } catch (error) {
        console.error("Error updating password:", error);
        this.showToast("An error occurred. Please try again.", "danger");
      }
    },
    async showToast(message, color) {
      const toast = await toastController.create({
        message: message,
        duration: 3000,
        color: color,
        position: "top",
      });
      await toast.present();
    },
    closeModal() {
      this.showModal = false;
      this.newPassword = ""; // Clear password input when closing modal
    },
    logout() {
      localStorage.removeItem("token");
      this.$router.push("/login"); // Redirect to login page after logout
    },
  },
  mounted() {
    defineCustomElements(window);
  },
};
</script>

<style scoped>
.hamburger {
  height: 50px;
  width: 50px;
  position: relative;
}

.hamburger .checkbox {
  position: absolute;
  opacity: 0;
  height: 100%;
  width: 100%;
  cursor: pointer;
}

.line {
  transition: 0.5s;
  stroke-width: 6px;
  stroke: black;
}

.lineTop {
  stroke-dasharray: 40 40;
  stroke-dashoffset: 25;
}

.lineBottom {
  stroke-dasharray: 40 40;
  stroke-dashoffset: 60;
}

.lineMid {
  stroke-dasharray: 40 40;
}

.hamburger .checkbox:checked + svg .line {
  stroke: crimson;
}

.hamburger .checkbox:checked + svg .lineTop {
  stroke-dashoffset: 0;
  transform-origin: left;
  transform: rotateZ(45deg) translate(-7px, -5px);
}

.hamburger .checkbox:checked + svg .lineMid {
  stroke-dashoffset: 40;
}

.hamburger .checkbox:checked + svg .lineBottom {
  stroke-dashoffset: 0;
  transform-origin: left;
  transform: rotateZ(-45deg) translate(-5px, 5px);
}

.menu-dropdown {
  position: absolute;
  top: 60px;
  right: -70px;
  border-radius: 8px;
  width: 150px;
  padding: 10px;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: column;
  background-color: white;
  box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1);
}

.menu-btn {
  background-color: rgb(43, 38, 39);
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 5px;
  font-size: 16px;
  cursor: pointer;
  transition: background-color 0.3s ease;
  width: 100%;
  margin-bottom: 10px;
  text-align: center;
}

.menu-btn:hover {
  background-color: darkred;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
}

.modal-content {
  background: white;
  padding: 20px;
  border-radius: 5px;
  width: 300px;
  text-align: center;
}

.button-edit {
  background-color: #4caf50;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  margin: 10px;
}

.button-edit:hover {
  background-color: #388e3c;
}

.button-cancel {
  background-color: #f44336;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.button-cancel:hover {
  background-color: #d32f2f;
}
</style>
