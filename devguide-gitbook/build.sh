#!/bin/bash
# gitbook build
docker build -t beimax/devguide-gitbook:latest .
docker push beimax/devguide-gitbook:latest