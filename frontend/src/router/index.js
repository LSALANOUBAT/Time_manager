import Vue from 'vue';
import Router from 'vue-router';
import UserLogin from '../components/UserLogin.vue'; // Updated name for Login component
import UserRegister from '../components/UserRegister.vue'; // Updated name for Register component
import UserDashboard from '../components/UserDashboard.vue'; // Updated name for Dashboard component
import { isAuthenticated } from './auth'; // Import of the authentication function

Vue.use(Router);

const router = new Router({
    mode: 'history', // Use HTML5 history mode (no #)
    routes: [
        {
            path: '/',
            redirect: '/login', // Redirect to login by default if the route is "/"
        },
        {
            path: '/login',
            component: UserLogin,
            meta: { requiresAuth: false }, // No authentication required for this route
        },
        {
            path: '/register',
            component: UserRegister,
            meta: { requiresAuth: false }, // No authentication required for this route
        },
        {
            path: '/dashboard', // Route for protected components like the dashboard
            component: UserDashboard,
            meta: { requiresAuth: true }, // This route requires authentication
        },
        {
            path: '*',
            redirect: '/login', // Redirect any unrecognized route to login
        },
    ],
});

// Middleware to protect routes requiring authentication
router.beforeEach((to, from, next) => {
    if (to.matched.some(record => record.meta.requiresAuth)) {
        if (!isAuthenticated()) {
            next('/login'); // Redirect to login if the user is not authenticated
        } else {
            next(); // Proceed if the user is authenticated
        }
    } else {
        next(); // Proceed if the route does not require authentication
    }
});

export default router;
