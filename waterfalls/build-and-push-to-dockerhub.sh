#!/bin/sh
set -eu

export WATERFALLS_REPO=https://github.com/RCasatta/waterfalls
export WATERFALLS_COMMIT_HASH=b8818e1bf21f89e1d64b5077fc35c1b6ff26f37e

exec sh "$(dirname "$0")/../scripts/publish.sh" build "blockstream/waterfalls:${WATERFALLS_COMMIT_HASH}" "" \
    --platform "${PLATFORMS:-linux/amd64,linux/arm64}" \
    --pull --no-cache \
    --build-arg WATERFALLS_COMMIT_HASH=${WATERFALLS_COMMIT_HASH} \
    .
