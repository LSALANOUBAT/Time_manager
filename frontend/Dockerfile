FROM node:latest

WORKDIR /front_app

COPY package*.json ./

RUN npm install


COPY . .


RUN npm run build

EXPOSE 8080


CMD ["npm", "run", "serve"]

