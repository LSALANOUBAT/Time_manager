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
        <button @click="logout" class="logout-btn">Logout</button>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    data() {
      return {
        isChecked: false, // Gère l'état du menu hamburger
      };
    },
    methods: {
      logout() {
        // Logique de déconnexion, similaire à celle dans App.vue
        localStorage.removeItem('token');
        this.$router.push('/login'); // Redirige vers la page de login après déconnexion
      },
    },
  };
  </script>
  
  <style scoped>
  .hamburger {
    height: 50px;
    width: 50px;
    transform: 0.2s;
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
  right: -70px; /* Ajustez cette valeur pour déplacer le menu plus à gauche */
  border-radius: 8px;
  width: 150px;
  padding: 10px;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: column;
}
  
  .logout-btn {
    background-color: crimson;
    color: white;
    border: none;
    padding: 10px 20px;
    border-radius: 5px;
    font-size: 16px;
    cursor: pointer;
    transition: background-color 0.3s ease;
  }
  
  .logout-btn:hover {
    background-color: darkred;
  }
  </style>
  