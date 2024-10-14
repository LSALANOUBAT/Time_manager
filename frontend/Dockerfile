FROM node:latest

WORKDIR /front_app

COPY package*.json ./

RUN npm install
RUN npm install vue-chartjs chart.js


COPY . .

EXPOSE 3000

RUN npm run build

CMD ["npm", "run", "serve"]

