#!/bin/bash

export VERSION=0.1.0
wget https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz
docker build -t c9golang:${VERSION} .
rm go1.6.linux-amd64.tar.gz
