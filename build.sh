#!/bin/bash

# Get the base name of the current directory
BASE=`basename $(pwd) | tr [:upper:] [:lower:]`
# If a parameter is given, use it as the base name
if [ -n "$1" ]; then
  BASE=`echo "$1" | tr [:upper:] [:lower:]`
fi

# Set desired Astrolog version
# https://www.astrolog.org/
# https://github.com/CruiserOne/Astrolog/releases
ASTROLOG_VERSION=${ASTROLOG_VERSION:-7.70}
if [ -n "$2" ]; then
  ASTROLOG_VERSION=$2
fi

LAMBDA_VERSION=${LAMBDA_VERSION:-3.9}
if [ -n "$2" ]; then
  LAMBDA_VERSION=$3
fi

# Build the image
docker build --platform=linux/amd64 \
  --build-arg ASTROLOG_VERSION=${ASTROLOG_VERSION} \
  --build-arg LAMBDA_VERSION=$(LAMBDA_VERSION) \
  --build-arg MAKE_ARGS=-j8 \
  -t $BASE . || exit $?

# Save the image as a tarball
docker save -o $BASE.tar $BASE

# get layer config file from tarball
tar xvf $BASE.tar repositories

# Get the layer name from repositories file
LAYER="blobs/sha256/$(jq -r '.|.[]|.[]' repositories)"

# extract layer from tarball
tar xvf $BASE.tar $LAYER

# expand layer from tarball, this layer contains the compiled binaries
tar xvf $LAYER

# remove intermediate fils
# rm -rf $BASE.tar repositories blobs

# List result:
ls ./out
