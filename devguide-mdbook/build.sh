#!/bin/bash
mdbook clean
mdbook build
docker build -t beimax/devguide-mdbook:latest .
docker push beimax/devguide-mdbook:latest