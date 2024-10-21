export function isAuthenticated() {
    return !!localStorage.getItem('token'); // Retourne true si le token JWT est présent
}
