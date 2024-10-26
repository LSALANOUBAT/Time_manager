import { createApp } from 'vue';
import { IonicVue } from '@ionic/vue';
import App from './App.vue';
   // import router for web
import router from '../src/router/index';
import "@/assets/styles.css"; // ou le chemin vers ton fichier CSS global


   // Import Ionic Core and the basic CSS
import '@ionic/vue/css/core.css';
import '@ionic/vue/css/normalize.css';
import '@ionic/vue/css/structure.css';
import '@ionic/vue/css/typography.css';


createApp(App)
    .use(IonicVue)
    .use(router)
    .mount('#app');