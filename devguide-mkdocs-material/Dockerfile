FROM python:2.7
RUN mkdir -p /ref1.5
COPY . /ref1.5/
WORKDIR /ref1.5
RUN pip install mkdocs
RUN pip install mkdocs-material
EXPOSE 8000
CMD ["mkdocs", "serve", "-a", "0.0.0.0:8000"]