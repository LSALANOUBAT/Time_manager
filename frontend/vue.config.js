const { defineConfig } = require('@vue/cli-service');
const TARGET=process.env.VUE_APP_API_TARGET;

module.exports = defineConfig({
  transpileDependencies: true,
  // Development server configuration
  devServer: {
    webSocketServer: false,
    host: '0.0.0.0',  // Permet l'accès depuis n'importe quelle interface réseau
    port: 8080,       // Spécifie le port sur lequel le serveur de développement tournera
    allowedHosts: [
      'vue.orbesle.fr',  // Autorise les requêtes provenant de ce domaine
      'localhost',       // Autorise les requêtes provenant de localhost
    ],
    headers: {
      'Access-Control-Allow-Origin': '*', // Active le CORS pour toutes les origines
    },
    proxy: {
      // Proxy pour les appels API normaux
      '/api': {
        target: TARGET,  // Proxy vers ton backend API
        changeOrigin: true,
        secure: false,
        ws: false  // Ajuste selon la configuration SSL de ton serveur
      },
    },
  },

  // Configuration supplémentaire de Webpack
  configureWebpack: {
    devtool: 'source-map', // Active les source maps pour faciliter le débogage
  },

  // Configurations avancées de Webpack avec chainWebpack
  chainWebpack: config => {
    // Ajoute des configurations avancées ici si nécessaire
  },
});
