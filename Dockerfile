FROM node:18-bullseye

WORKDIR /home/node

COPY package*.json .
RUN npm install
RUN npm install -g eslint

COPY . .

EXPOSE 3000
CMD [ "npm", "run", "start" ]