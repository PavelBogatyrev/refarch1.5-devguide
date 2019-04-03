#!/bin/bash
pip install -U Sphinx
pip install recommonmark
pip install sphinx-markdown-tables==0.0.9
rm -rf build
make html
docker build -t beimax/devguide-sphinx:latest .
docker push beimax/devguide-sphinx:latest 