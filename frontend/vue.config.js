const webpack = require('webpack');


module.exports = {
  transpileDependencies: true,

  devServer: {
    host: '0.0.0.0',
    port: 8080,
    allowedHosts: [
      'web.orbesle.fr',
      'localhost'
    ],
    headers: {
      'Access-Control-Allow-Origin': '*', 
    },
    proxy: {
      '/': {
        target: process.env.VUE_APP_API_TARGET,  // Use correct domain based on environment
        changeOrigin: true,
      },
    },
    hot: false,
    liveReload: false,
  },
};
