#!/bin/sh
# Authenticate only the registries selected for this publishing job.
set +x
set -eu
set -f
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/registry-common.sh"

# Release tags retain Docker Hub publishing; copies run later on master.
if [ -n "${CI_COMMIT_TAG:-}" ]; then export PUBLISH_MIRRORS=false; fi
if [ "${CI_PIPELINE_SOURCE:-}" = merge_request_event ]; then export PUSH=false; fi

[ "${PUSH:-true}" != false ] || exit 0
prefixes=$(publish_repositories "${1:-blockstream}")
case "${2:-DOCKERHUB_PW}" in
    DOCKERHUB_PW) hub_password=${DOCKERHUB_PW:-} ;;
    DOCKERHUB_PASSWORD) hub_password=${DOCKERHUB_PASSWORD:-} ;;
    *) fail 'Unsupported Docker Hub password variable' ;;
esac
hosts=
hub=false
for prefix in $prefixes; do
    case "$prefix" in
        */*) host=${prefix%%/*}; case "$host" in *.*|*:*|localhost) ;; *) host=docker.io ;; esac ;;
        *) host=docker.io ;;
    esac
    case " $hosts " in *" $host "*) continue ;; esac
    hosts="${hosts:+$hosts }$host"
    [ "$host" != docker.io ] || hub=true
done
if [ "$hub" = true ] && [ -n "${DOCKERHUB_USER:-}" ] && [ -n "$hub_password" ]; then
    printf '%s\n' "$hub_password" | docker login -u "$DOCKERHUB_USER" --password-stdin
fi
unset hub_password
if [ "${PUBLISH_MIRRORS:-true}" = false ] || [ "$hosts" = docker.io ]; then exit 0; fi
if [ -n "${MIRROR_REGISTRY:-}" ] && [ -n "${MIRROR_REGISTRY_USER:-}" ] &&
    [ -n "${MIRROR_REGISTRY_PASSWORD:-}" ]; then
    case " $hosts " in
        *" $MIRROR_REGISTRY "*)
            # Expand the username exactly once, preserving literal dollar signs.
            printf '%s\n' "$MIRROR_REGISTRY_PASSWORD" |
                docker login "$MIRROR_REGISTRY" -u "$MIRROR_REGISTRY_USER" --password-stdin
            ;;
    esac
fi
set --
for host in $hosts; do
    case "$host" in *-docker.pkg.dev) set -- "$@" "$host" ;; esac
done
[ "$#" -eq 0 ] || sh "$script_dir/google-token-login.sh" "$@"
