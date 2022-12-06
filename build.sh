#!/bin/bash

VERSION=7.50

BASE=`basename $(pwd) | tr [:upper:] [:lower:]`
if [ -n "$1" ]; then
  BASE=`echo "$1" | tr [:upper:] [:lower:]`
fi

docker build --build-arg VERSION=${VERSION} -t $BASE . || exit $?

docker save -o $BASE.tar $BASE

# get layer config
tar xvf $BASE.tar repositories
LAYER=$(jq -r '.|.[]|.[]' repositories)

# extract layer
tar xvf $BASE.tar $LAYER/layer.tar

# expand layer
tar xvf $LAYER/layer.tar

# remove intermediate fils
rm -rf $BASE.tar repositories $LAYER

# debug result:
ls out

