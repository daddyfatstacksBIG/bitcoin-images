#!/bin/sh
set -eu

export VER=a33e97e1a1fc63fa9c20a116bb92579bbf43b254

exec sh "$(dirname "$0")/../scripts/publish.sh" build "blockstream/electrsd-liquid:${VER}" "latest" \
    --platform "${PLATFORMS:-linux/amd64,linux/arm64}" \
    --pull --no-cache \
    --build-arg ELECTRSD_VERSION=${VER} \
    .
