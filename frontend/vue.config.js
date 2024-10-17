const { defineConfig } = require('@vue/cli-service')

module.exports = defineConfig({
  transpileDependencies: true,
  devServer: {
    host: '0.0.0.0',  // Écoute sur toutes les interfaces réseau
    port: 8080,       // Le port sur lequel Vue.js doit écouter
    allowedHosts: [
      'vue.orbesle.fr'  // Accepte les requêtes provenant de ce domaine
    ],
    client: {
      webSocketURL: 'wss://vue.orbesle.fr/ws',  // WebSocket pour Live Reload (HTTPS)
    },
    headers: {
      'Access-Control-Allow-Origin': '*', // Pour éviter les problèmes CORS
    },
  },
})
