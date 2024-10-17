FROM node:latest

WORKDIR /front_app

COPY package*.json ./

RUN npm install
RUN npm install vue-chartjs chart.js
RUN npm install -g @vue/cli
RUN npm install
RUN npm install vue-chartjs chart.js

COPY . .

# Construire le projet
RUN npm run build

# Exposer le port 8080
EXPOSE 8080

# Lancer le serveur de développement Vue avec les paramètres nécessaires
CMD ["vue-cli-service", "serve", "--host", "0.0.0.0", "--disableHostCheck", "true"]
