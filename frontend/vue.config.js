module.exports = {
  transpileDependencies: true,

  devServer: {
    host: '0.0.0.0',  // Bind to all IPs
    port: 8080,       // Port where the app will run
    allowedHosts: 'all',  // Allow all hosts to prevent "Invalid Host header"
    headers: {
      'Access-Control-Allow-Origin': '*', 
    },
    proxy: {
      '/api': {
        target: process.env.VUE_APP_API_TARGET,  // Proxy API requests
        changeOrigin: true,
      },
    },
    hot: false,
    liveReload: false,
    disableHostCheck: true,  // Disable the host check to avoid the Invalid Host header issue
  },
};
