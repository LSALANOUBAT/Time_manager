const { defineConfig } = require('@vue/cli-service');
const webpack = require('webpack');

module.exports = defineConfig({
  transpileDependencies: true,

  devServer: {
    host: '0.0.0.0',
    port: 8080,
    allowedHosts: [
      'vue.orbesle.fr',
      'localhost:8080'
    ],
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
    proxy: {
      '/': {
        target: process.env.VUE_APP_API_URL,
        changeOrigin: true,
      },
    },
    hot: false,
    liveReload: false,

    // Fix the client and webSocketURL options
    client: {
      webSocketURL: {
        hostname: 'localhost',   // or 'vue.orbesle.fr' depending on your setup
        port: 8080,              // port of your dev server
        protocol: 'ws',          // or 'wss' if using SSL
      },
    },
  },

  configureWebpack: {
    plugins: [
      new webpack.DefinePlugin({
        __VUE_PROD_DEVTOOLS__: false,
        __VUE_OPTIONS_API__: true,
      }),
    ],
  },
});
