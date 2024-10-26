import { createRouter, createWebHistory } from 'vue-router';
import UserLogin from '../components/User/UserLogin.vue';
import UserDashboard from '../components/UserDashboard.vue';
import { isAuthenticated } from './auth';

// Define your routes with meta titles
const routes = [
    {
        path: '/',
        redirect: '/login',
        meta: { title: "Login - Gotham City Police Time Manager" },
    },
    {
        path: '/login',
        component: UserLogin,
        meta: { requiresAuth: false, title: "Login - Gotham City Police Time Manager" },
    },

    {
        path: '/dashboard',
        component: UserDashboard,
        meta: { requiresAuth: true, title: "Dashboard - Gotham City Police Time Manager" },
    },
    {
        path: '/:catchAll(.*)',
        redirect: '/login',
        meta: { title: "Login - Gotham City Police Time Manager" },
    },
];

// Create the router instance
const router = createRouter({
    history: createWebHistory(),
    routes,
});

// Set the document title based on route meta title
router.beforeEach((to, from, next) => {
    if (to.meta.title) {
        document.title = to.meta.title; // Set the browser tab title
    }

    if (to.matched.some(record => record.meta.requiresAuth)) {
        if (!isAuthenticated()) {
            next('/login');
        } else {
            next();
        }
    } else {
        next();
    }
});

export default router;
