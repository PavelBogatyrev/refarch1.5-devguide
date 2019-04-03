#!/bin/bash
rm -rf _book
gitbook buuild
docker build -t beimax/devguide-gitbook:latest .
docker push beimax/devguide-gitbook:latest 