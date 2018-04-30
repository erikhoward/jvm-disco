#!/bin/bash

# docker hub username
IMAGEPREFIX=erikhoward

# image name
IMAGE=jvm-disco

# make sure we're up to date
git pull

# bump version
docker run --rm -v "$PWD":/app treeder/bump patch
version=`cat VERSION`
echo "version: $version"

# run build
./build.sh

# tag it
git commit -m "version $version"
git tag -a "$version" -m "version $version"
git push
git push --tags

docker tag $IMAGEPREFIX/$IMAGE:latest $IMAGEPREFIX/$IMAGE:$version

# push to docker hub
docker push $IMAGEPREFIX/$IMAGE:latest
docker push $IMAGEPREFIX/$IMAGE:$version
