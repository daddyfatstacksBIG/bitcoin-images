#!/usr/bin/env bash
set -eu

export CLN_VER="${CLN_VER:-v26.06.9}"
export PS_VER="${PS_VER:-v7.0.0}"
export BITCOIN_VER="${BITCOIN_VER:-31.1}"
export ELEMENTS_VER="${ELEMENTS_VER:-23.3.3}"
export GO_VERSION="${GO_VERSION:-1.26.10}"
export RUST_VERSION="${RUST_VERSION:-1.98.0}"
export UV_VERSION="${UV_VERSION:-0.12.0}"
export PYLN_VERSION="${PYLN_VERSION:-26.6.9}"

exec sh "$(dirname "$0")/../../scripts/publish.sh" build "blockstream/lightningd:${CLN_VER}-peerswap-debian" "${CLN_VER}-peerswap-debian-${PS_VER}" \
    --platform "${PLATFORMS:-linux/amd64}" \
    --pull --no-cache \
    --build-arg "CLN_VER=${CLN_VER}" \
    --build-arg "PEERSWAP_VER=${PS_VER}" \
    --build-arg "BITCOIN_VER=${BITCOIN_VER}" \
    --build-arg "ELEMENTS_VER=${ELEMENTS_VER}" \
    --build-arg "GO_VERSION=${GO_VERSION}" \
    --build-arg "RUST_VERSION=${RUST_VERSION}" \
    --build-arg "UV_VERSION=${UV_VERSION}" \
    --build-arg "PYLN_VERSION=${PYLN_VERSION}" \
    -f Dockerfile \
    .
