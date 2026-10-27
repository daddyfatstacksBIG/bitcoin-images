#!/bin/sh

export VER=0.9.5

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    --pull \
    --no-cache \
    --build-arg VER=${VER} \
    -t blockstream/hal-docker:${VER} \
    -t blockstream/hal-docker:latest . || { echo -e "\nSomething broke"; exit 1; }
