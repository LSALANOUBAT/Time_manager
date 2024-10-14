FROM node:latest

WORKDIR /front_app

COPY package*.json ./

RUN npm install -g npm@latest && npm install
RUN npm install
RUN npm install vue-chartjs chart.js


COPY . .


RUN npm run build

EXPOSE 8080


CMD ["npm", "run", "serve"]

