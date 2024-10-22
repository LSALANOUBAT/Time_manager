const { defineConfig } = require('@vue/cli-service');

module.exports = defineConfig({
  transpileDependencies: true,

  // Development server configuration
  devServer: {
    host: '0.0.0.0',  // Allows access from any network interface
    port: 8080,       // Specifies the port for the dev server
    allowedHosts: [
      'vue.orbesle.fr',  // Allows requests from this domain
      'localhost',       // Allows requests from localhost
    ],
    headers: {
      'Access-Control-Allow-Origin': '*', // Enables CORS for all origins
    },
    proxy: {
      // Proxy for normal API calls
      '/api': {
        target: 'https://web.orbesle.fr',  // Proxy to your backend API
        changeOrigin: true,
        secure: false,  // Adjust based on your SSL configuration
      },
      // Proxy for WebSocket connections
      '/ws': {
        target: 'http://localhost:8080', // Default target, replace if necessary
        ws: true,               // Indicates that this is for WebSocket
        changeOrigin: true,     // Changes the origin of the request to match the target domain
        pathRewrite: { '^/ws': '' }, // Optional URL rewrite
        router: function (req) {
          return 'wss://web.orbesle.fr'; // WebSocket server URL
        },
      },
    },
  },

  // Webpack configuration
  configureWebpack: {
    devtool: 'source-map', // Enable source maps for easier debugging
  },

  // Advanced Webpack configurations with chainWebpack
  chainWebpack: config => {
    // Add advanced configurations here if needed
  },
});
