<template>
    <div>
      <!-- Button to Open Modal -->
      <button @click="showModal = true">Change Password</button>
  
      <!-- Modal Structure -->
      <div v-if="showModal" class="modal-overlay" @click.self="closeModal">
        <div class="modal-content">
          <h3>Update Password</h3>
          <input
            v-model="newPassword"
            type="password"
            placeholder="Enter new password"
          />
          <button @click="updatePassword">Update Password</button>
          <button @click="closeModal">Cancel</button>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  import { toastController } from "@ionic/vue";
  
  export default {
    data() {
      return {
        showModal: false,
        newPassword: "",
      };
    },
    methods: {
      async updatePassword() {
        const token = localStorage.getItem("token");
        try {
          const response = await fetch(
            `${process.env.VUE_APP_API_URL}/update_password`,
            {
              method: "PUT",
              headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${token}`,
              },
              body: JSON.stringify({ password: this.newPassword }),
            }
          );
  
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
        toast.present();
      },
      closeModal() {
        this.showModal = false;
        this.newPassword = ""; // Clear password input when closing modal
      },
    },
  };
  </script>
  
  <style scoped>
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
  </style>
  