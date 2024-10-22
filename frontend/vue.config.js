const { defineConfig } = require('@vue/cli-service');

module.exports = defineConfig({
  transpileDependencies: true,

  // Development server configuration
  devServer: {
    host: '0.0.0.0',  // Permet l'accès depuis n'importe quelle interface réseau
    port: 8080,       // Spécifie le port sur lequel le serveur tournera
    allowedHosts: [
      'vue.orbesle.fr',  // Autorise les requêtes depuis ce domaine
      'localhost',       // Autorise les requêtes depuis localhost
    ],
    headers: {
      'Access-Control-Allow-Origin': '*', // Active le CORS pour toutes les origines
    },
    proxy: {
      // Proxy pour les appels API normaux
      '/api': {
        target: 'https://web.orbesle.fr',  // Proxy vers ton backend API
        changeOrigin: true,
        secure: false,  // Ajuste selon la configuration SSL de ton serveur
      },
      // Proxy pour les connexions WebSocket
      '/ws': {
        ws: true,               // Spécifie que cette configuration concerne un WebSocket
        changeOrigin: true,     // Change l'origine de la requête pour correspondre au domaine cible
        pathRewrite: { '^/ws': '' }, // Réécrit l'URL si nécessaire (optionnel)
        router: function (req) {
          // Redirige soit vers le serveur distant, soit vers localhost
          if (req.headers.host.includes('localhost')) {
            return 'http://localhost:8080';
          }
          return 'wss://web.orbesle.fr';
        },
      },
    },
  },

  // Configurations Webpack supplémentaires
  configureWebpack: {
    // Ajoute des configurations Webpack personnalisées ici si nécessaire
  },

  // Configurations Webpack avancées avec chainWebpack
  chainWebpack: config => {
    // Utilise chainWebpack pour des configurations plus avancées
  },
});
