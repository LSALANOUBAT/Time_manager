<template>
  <div id="app">
    <header>
      <h1>Time Manager Application</h1>
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
import UserManager from './components/UserManager.vue'; // Updated import
import WorkingTimes from './components/WorkingTimes.vue';
import WorkingTime from './components/WorkingTime.vue';
import ClockManager from './components/ClockManager.vue';
import ChartManager from './components/ChartManager.vue';

export default {
  name: 'App',
  components: {
    UserManager, // Updated component reference
    WorkingTimes,
    WorkingTime,
    ClockManager,
    ChartManager,
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
</style>
