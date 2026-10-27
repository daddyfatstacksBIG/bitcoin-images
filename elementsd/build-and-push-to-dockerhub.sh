#!/bin/sh
set -ex

export VER=${VER:-23.3.4}
docker buildx build --platform linux/amd64,linux/arm64 \
  --push \
  --pull \
  --no-cache \
  --build-arg ELEMENTS_VERSION=${VER} \
  --build-arg GH_REPO \
  -t blockstream/elementsd:${VER} . || { echo -e "\nSomething broke"; exit 1; }

if [[ $LATEST -eq 1 ]]
then
  docker buildx imagetools create -t blockstream/elementsd:latest blockstream/elementsd:${VER}
fi
