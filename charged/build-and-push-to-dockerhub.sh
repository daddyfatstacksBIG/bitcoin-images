#!/bin/sh
set -eu

export VER=v0.4.26

exec sh "$(dirname "$0")/../scripts/publish.sh" build "blockstream/charged:${VER}" "latest" \
    --platform "${PLATFORMS:-linux/amd64,linux/arm64}" \
    --pull --no-cache \
    --build-arg CHARGED_VERSION=${VER} \
    .
