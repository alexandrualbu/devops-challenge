FROM node:18-bullseye

WORKDIR /home/node

COPY package.json .
RUN npm install

COPY . .

EXPOSE 3000
CMD [ "npm", "run", "start" ]