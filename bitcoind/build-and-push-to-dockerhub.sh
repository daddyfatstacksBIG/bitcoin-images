#!/bin/sh
set -eu

export VER=${VER:-31.1}

extra_tags=
[ "${LATEST:-0}" != 1 ] || extra_tags=latest

exec sh "$(dirname "$0")/../scripts/publish.sh" build "blockstream/bitcoind:${VER}" "${extra_tags}" \
    --platform "${PLATFORMS:-linux/amd64,linux/arm64}" \
    --pull --no-cache \
    --build-arg BITCOIN_VERSION="${VER}" \
    .
