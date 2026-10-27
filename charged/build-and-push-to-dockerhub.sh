#!/bin/sh
set -ex

export VER=v0.4.26

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    --pull \
    --no-cache \
    --build-arg CHARGED_VERSION=${VER} \
    -t blockstream/charged:$VER \
    -t blockstream/charged:latest . || `echo -e "\nSomething broke" && exit 1`
