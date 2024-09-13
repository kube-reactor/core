#!/bin/bash
#-------------------------------------------------------------------------------
set -e

export __reactor_docker_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export __reactor_dir="$(dirname "${__reactor_docker_dir}")"

RUNTIME="${1:-standard}"

VERSION="${2:-}"
if [ -z "$VERSION" ]; then
    VERSION="$(cat "${__reactor_dir}/VERSION")"
fi

if [ -z "$PKG_DOCKER_USER" ]; then
    echo "PKG_DOCKER_USER environment variable must be defined to deploy application"
    exit 1
fi
if [ -z "$PKG_DOCKER_PASSWORD" ]; then
    echo "PKG_DOCKER_PASSWORD environment variable must be defined to deploy application"
    exit 1
fi

PKG_DOCKER_IMAGE="${PKG_DOCKER_IMAGE:-zimagi/reactor}"

#-------------------------------------------------------------------------------

echo "Logging into DockerHub"
echo "$PKG_DOCKER_PASSWORD" | docker login --username "$PKG_DOCKER_USER" --password-stdin

echo "Creating Docker manifest: ${REACTOR_TAG}"
REACTOR_TAG="$VERSION"

if [ "$RUNTIME" = "standard" ]; then
    docker manifest create "${PKG_DOCKER_IMAGE}:${REACTOR_TAG}" \
        --amend "${PKG_DOCKER_IMAGE}:${REACTOR_TAG}-amd64" \
        --amend "${PKG_DOCKER_IMAGE}:${REACTOR_TAG}-arm64"
else
    REACTOR_TAG="${RUNTIME}-${REACTOR_TAG}"

    if [ "$RUNTIME" != "nvidia" ]; then
        echo "Reactor Docker runtime not supported: ${RUNTIME}"
        exit 1
    fi

    docker manifest create "${PKG_DOCKER_IMAGE}:${REACTOR_TAG}" \
        --amend "${PKG_DOCKER_IMAGE}:${REACTOR_TAG}-amd64"
fi

echo "Pushing Docker manifest: ${REACTOR_TAG}"
docker manifest push "${PKG_DOCKER_IMAGE}:${REACTOR_TAG}"
