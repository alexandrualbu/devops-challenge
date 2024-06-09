FROM node:14

WORKDIR /home/node

COPY package*.json .
RUN npm install
RUN npm install -g eslint

COPY . .

EXPOSE 3000
CMD [ "npm", "run", "start" ]