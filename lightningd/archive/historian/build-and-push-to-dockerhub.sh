#!/usr/bin/env bash
set -eu

export CLN_VER=${CLN_VER:-v25.05}

exec sh "$(dirname "$0")/../../../scripts/publish.sh" build "blockstream/lightningd:${CLN_VER}-historian" "" \
    --platform "${PLATFORMS:-linux/amd64}" \
    --cache-from blockstream/lightningd:latest \
    --build-arg CLN_VER=${CLN_VER} \
    .
