#!/bin/sh
set -ex

export WATERFALLS_REPO=https://github.com/RCasatta/waterfalls
export WATERFALLS_COMMIT_HASH=b8818e1bf21f89e1d64b5077fc35c1b6ff26f37e

# The latest tag is published separately; this job pushes only the commit tag.
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    --pull \
    --no-cache \
    --build-arg WATERFALLS_COMMIT_HASH=${WATERFALLS_COMMIT_HASH} \
    -t blockstream/waterfalls:$WATERFALLS_COMMIT_HASH . || `echo -e "\nSomething broke" && exit 1`

echo "pushed blockstream/waterfalls:$WATERFALLS_COMMIT_HASH"

exit 0
