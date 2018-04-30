#!/bin/bash

set -ex

#docker hub username
IMAGEPREFIX=erikhoward

#image name
IMAGE=jvm-disco

docker build -t $IMAGEPREFIX/$IMAGE:latest .
