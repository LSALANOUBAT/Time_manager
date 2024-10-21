import Vue from 'vue';
import Router from 'vue-router';
import Login from '../components/Login.vue';
import Register from '../components/Register.vue';
import Dashboard from '../components/Dashboard.vue'; // Remplace par ton composant principal après connexion
import { isAuthenticated } from './auth'; // Import de la fonction d'authentification

Vue.use(Router);

const router = new Router({
    mode: 'history', // Utilise l'historique HTML5 (sans #)
    routes: [
        {
            path: '/',
            redirect: '/login', // Rediriger vers login par défaut si la route est "/"
        },
        {
            path: '/login',
            component: Login,
            meta: { requiresAuth: false }, // Pas besoin d'authentification pour cette route
        },
        {
            path: '/register',
            component: Register,
            meta: { requiresAuth: false }, // Pas besoin d'authentification pour cette route
        },
        {
            path: '/dashboard', // Route pour les composants protégés (comme ton tableau de bord)
            component: Dashboard,
            meta: { requiresAuth: true }, // Cette route nécessite l'authentification
        },
        {
            path: '*',
            redirect: '/login', // Rediriger toute route non reconnue vers login
        },
    ],
});

// Middleware pour protéger les routes nécessitant une authentification
router.beforeEach((to, from, next) => {
    if (to.matched.some(record => record.meta.requiresAuth)) {
        if (!isAuthenticated()) {
            next('/login'); // Rediriger vers login si l'utilisateur n'est pas authentifié
        } else {
            next(); // Continuer si l'utilisateur est authentifié
        }
    } else {
        next(); // Continuer si la route ne nécessite pas d'authentification
    }
});

export default router;
