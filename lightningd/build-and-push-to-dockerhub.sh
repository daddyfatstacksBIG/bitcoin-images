#!/usr/bin/env bash
set -eu

export VER=${VER:-v26.06.9}

extra_tags=
[ "${LATEST:-0}" != 1 ] || extra_tags=latest

exec sh "$(dirname "$0")/../scripts/publish.sh" build "blockstream/lightningd:${VER}" "${extra_tags}" \
    --platform "${PLATFORMS:-linux/amd64}" \
    --pull --no-cache \
    --build-arg VER=${VER} \
    .
