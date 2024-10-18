const { defineConfig } = require('@vue/cli-service');

module.exports = defineConfig({
  transpileDependencies: true,

  // Development server configuration
  devServer: {
    host: '0.0.0.0',  // Allows access from any network interface (useful for Docker or LAN access)
    port: 8080,       // Specifies the port on which the server will run
    allowedHosts: [
      'vue.orbesle.fr',
      'localhost:8080'  // Accept requests from this host/domain
    ],
    headers: {
      'Access-Control-Allow-Origin': '*', // Enables CORS for all origins
    },
    // If needed, you can add proxy settings for backend API calls
    proxy: {
      '/api': {
        target: 'http://localhost:4000',
        changeOrigin: true,
      },
    },
  },

  // Adjusting webpack configurations if necessary
  configureWebpack: {
    // Custom webpack configurations can be added here
  },

  // Optional: ChainWebpack for more advanced configurations
  chainWebpack: config => {
    // Example of chaining additional configurations
  },
});