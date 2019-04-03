FROM node
RUN npm install gitbook-cli -g
RUN gitbook fetch 3.2.3
WORKDIR /usr/src/app
COPY . ./
EXPOSE 4000
CMD [ "gitbook", "serve" ]
