#!/bin/sh
set -eu

export VER=v0.4.0

exec sh "$(dirname "$0")/../scripts/publish.sh" build "blockstream/btc-rpc-proxy:${VER}" "latest" \
    --platform "${PLATFORMS:-linux/amd64,linux/arm64}" \
    --pull --no-cache \
    --build-arg VER=${VER} \
    .
