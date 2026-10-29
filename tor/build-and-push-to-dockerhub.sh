#!/bin/sh
set -eu

TOR_VERSION=0.4.9.11

exec sh "$(dirname "$0")/../scripts/publish.sh" build "blockstream/tor:${TOR_VERSION}" "" \
    --platform "${PLATFORMS:-linux/amd64,linux/arm64}" \
    --pull --no-cache \
    --build-arg TOR_VERSION="${TOR_VERSION}" \
    .
