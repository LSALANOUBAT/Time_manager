import Vue from 'vue';
import App from './App.vue';
import router from './router'; // Import du routeur

Vue.config.productionTip = false;

new Vue({
    router, // Utilisation du routeur dans l'application Vue
    render: h => h(App),
}).$mount('#app');
