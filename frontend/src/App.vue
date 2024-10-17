<template>
  <div id="app">
    <header>
      <h1>Time Manager Application</h1>
      <button @click="readPageContent">Lire cette page</button>
    </header>
    <main>
      <UserManager />
      <WorkingTimes />
      <WorkingTime />
      <ClockManager />
      <ChartManager />
    </main>
  </div>
</template>

<script>
import UserManager from './components/UserManager.vue';
import WorkingTimes from './components/WorkingTimes.vue';
import WorkingTime from './components/WorkingTime.vue';
import ClockManager from './components/ClockManager.vue';
import ChartManager from './components/ChartManager.vue';

export default {
  name: 'App',
  components: {
    UserManager,
    WorkingTimes,
    WorkingTime,
    ClockManager,
    ChartManager,
  },
  methods: {
    readPageContent() {
      const content = document.body.innerText; // Récupère tout le texte visible de la page
      if ('speechSynthesis' in window) {
        const speech = new SpeechSynthesisUtterance(content); // Crée une instance de synthèse vocale
        speech.lang = 'fr-FR'; // Définit la langue à français (modifiez si nécessaire)
        window.speechSynthesis.speak(speech); // Lance la lecture du texte
      } else {
        alert("Votre navigateur ne supporte pas la synthèse vocale.");
      }
    },
  },
};
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  text-align: center;
  color: #2c3e50;
  margin-top: 20px;
}

header {
  background-color: #42b983;
  padding: 10px;
  color: white;
}

main {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
  margin-top: 20px;
}

main > * {
  width: 80%;
  max-width: 800px;
  padding: 10px;
  border: 1px solid #ccc;
  border-radius: 5px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

button {
  margin-top: 10px;
  padding: 10px 20px;
  font-size: 16px;
  cursor: pointer;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 5px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

button:hover {
  background-color: #0056b3;
}
</style>
