#!/bin/sh
# Usage: publish.sh build|index|promote SOURCE_IMAGE:TAG 'EXTRA_TAGS' [arguments...]
# build arguments include the context. index arguments are source manifests.
set -eu
set -f
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/registry-common.sh"

# Release tags retain Docker Hub publishing; copies run later on master.
if [ -n "${CI_COMMIT_TAG:-}" ]; then export PUBLISH_MIRRORS=false; fi
if [ "${CI_PIPELINE_SOURCE:-}" = merge_request_event ]; then export PUSH=false; fi
operation=${1:?operation required}
source_ref=${2:?source image:tag required}
extra_tags=${3-}
shift 3
case "$source_ref" in */*:* ) ;; *) fail 'Expected a repository/image:tag reference' ;; esac
name_tag=${source_ref##*/}
name=${name_tag%:*}
version=${name_tag##*:}
source_prefix=${source_ref%/*}
prefixes=$(publish_repositories "$source_prefix")

case "${PUSH:-true}" in
    false)
        [ "$operation" = build ] || fail 'PUSH=false supports build validation only'
        exec docker buildx build --output type=cacheonly "$@"
        ;;
    true) ;;
    *) fail 'PUSH must be true or false' ;;
esac
case "$operation" in build|index|promote) ;; *) fail "Unknown operation: $operation" ;; esac

if [ "$operation" = promote ]; then
    if [ "${PUBLISH_MIRRORS:-true}" = false ]; then
        printf '%s\n' 'Additional registries disabled'
        exit 0
    fi
    destinations=
    for prefix in $prefixes; do
        [ "${prefix#docker.io/}" != "${source_prefix#docker.io/}" ] || continue
        destinations="${destinations:+$destinations }$prefix"
    done
    [ -n "$destinations" ] || { printf '%s\n' 'No additional registries configured'; exit 0; }
    digest=$(image_digest "$source_ref") || fail "Cannot resolve source $source_ref"
    # Resolve once and preflight every destination before the first write.
    for prefix in $destinations; do
        for tag in "$version" $extra_tags; do
            check_destination "$prefix/$name:$tag" "$digest"
        done
    done
    for prefix in $destinations; do
        for tag in "$version" $extra_tags; do
            docker buildx imagetools create --prefer-index=false \
                -t "$prefix/$name:$tag" "${source_ref%:*}@$digest"
            verify_digest "$prefix/$name:$tag" "$digest"
        done
    done
    exit 0
fi

for prefix in $prefixes; do
    for tag in "$version" $extra_tags; do
        # Only the existing latest aliases are mutable without FORCE.
        case "$tag" in latest|latest-*) ;; *) check_destination "$prefix/$name:$tag" ;; esac
        set -- "$@" -t "$prefix/$name:$tag"
    done
done
case "$operation" in
    build) docker buildx build --push "$@" ;;
    index) docker buildx imagetools create "$@" ;;
esac
expected=
for prefix in $prefixes; do
    for tag in "$version" $extra_tags; do
        ref="$prefix/$name:$tag"
        if [ -z "$expected" ]; then
            expected=$(image_digest "$ref") || fail "Cannot verify $ref"
        fi
        verify_digest "$ref" "$expected"
    done
done
printf 'Published index digest: %s\n' "$expected"
