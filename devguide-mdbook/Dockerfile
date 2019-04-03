FROM beimax/mdbook:0.2.3
RUN mkdir -p /ref1.5
WORKDIR /ref1.5/
COPY . book /ref1.5/
EXPOSE 3000
CMD [ "mdbook", "serve", "-p", "3000",  "-n", "0.0.0.0" ]