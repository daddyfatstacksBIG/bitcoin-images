#!/bin/sh
# Shared repository selection and manifest checks. Source from publishing scripts.

fail() { printf '%s\n' "$*" >&2; exit 1; }

publish_repositories() {
    default_prefix=$1
    repositories=${PUBLISH_REPOSITORIES:-$default_prefix}
    if [ "${PUBLISH_MIRRORS:-true}" = false ]; then
        repositories=$default_prefix
    fi
    selected=
    for prefix in $repositories; do
        prefix=${prefix%/}
        case "$prefix" in
            ''|*://*|*@*|*[!a-zA-Z0-9./:_-]*) fail "Invalid repository prefix: $prefix" ;;
        esac
        # Treat the explicit Docker Hub spelling as the same destination.
        case "$prefix" in docker.io/*) prefix=${prefix#docker.io/} ;; esac
        case " $selected " in *" $prefix "*) continue ;; esac
        selected="${selected:+$selected }$prefix"
    done
    [ -n "$selected" ] || fail 'PUBLISH_REPOSITORIES must contain a repository prefix'
    printf '%s\n' "$selected"
}

# Status 3 means the registry explicitly reported a missing manifest.
# Authentication, transport and unexpected responses are always fatal.
image_digest() {
    if result=$(docker buildx imagetools inspect "$1" --format '{{.Manifest.Digest}}' 2>&1); then
        printf '%s\n' "$result" | grep -Eq '^sha256:[a-f0-9]{64}$' ||
            fail "Invalid manifest digest for $1"
        printf '%s\n' "$result"
    else
        case "$result" in
            *'manifest unknown'*|*'MANIFEST_UNKNOWN'*|*'no such manifest'*|*"$1: not found"*) return 3 ;;
            *) fail "Cannot inspect $1: $result" ;;
        esac
    fi
}

check_destination() {
    destination=$1
    expected=${2:-}
    if current=$(image_digest "$destination"); then
        [ -n "$expected" ] && [ "$current" = "$expected" ] && return 0
        [ "${FORCE:-0}" = 1 ] ||
            fail "Refusing to overwrite $destination ($current); use a new version or FORCE=1"
    else
        status=$?
        [ "$status" -eq 3 ] || exit "$status"
    fi
}

verify_digest() {
    actual=$(image_digest "$1") || fail "Cannot verify $1"
    [ "$actual" = "$2" ] || fail "Digest mismatch for $1: $actual != $2"
    printf 'Verified %s = %s\n' "$1" "$actual"
}
