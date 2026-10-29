#!/bin/sh
set -eu

export VER=${VER:-23.3.4}

extra_tags=
[ "${LATEST:-0}" != 1 ] || extra_tags=latest

exec sh "$(dirname "$0")/../scripts/publish.sh" build "blockstream/elementsd:${VER}" "${extra_tags}" \
    --platform "${PLATFORMS:-linux/amd64,linux/arm64}" \
    --pull --no-cache \
    --build-arg ELEMENTS_VERSION="${VER}" \
    --build-arg GH_REPO \
    .
