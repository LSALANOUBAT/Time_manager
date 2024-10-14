FROM node:latest

WORKDIR /front_app

COPY package*.json ./

RUN npm install
RUN npm install vue-chartjs chart.js


COPY . .


RUN npm run build

EXPOSE 3000


CMD ["npm", "run", "serve"]

