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
      '/api': {
        target: process.env.VUE_APP_API_TARGET,
        changeOrigin: true,
      },
    },
    hot: false,
    liveReload: false,
    client: {
      webSocketURL: {
        hostname: 'localhost',
        port: 8080,
        protocol: 'ws',
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
