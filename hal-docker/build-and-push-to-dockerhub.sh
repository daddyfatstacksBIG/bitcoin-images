#!/bin/sh
set -eu

export VER=0.9.5

exec sh "$(dirname "$0")/../scripts/publish.sh" build "blockstream/hal-docker:${VER}" "latest" \
    --platform "${PLATFORMS:-linux/amd64,linux/arm64}" \
    --pull --no-cache \
    --build-arg VER=${VER} \
    .
