#!/bin/bash
#-------------------------------------------------------------------------------
set -e

export __reactor_docker_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export __reactor_dir="$(dirname "${__reactor_docker_dir}")"

case $(uname -m) in
  x86_64 | amd64) __architecture="amd64" ;;
  aarch64 | arm64) __architecture="arm64" ;;
  *) echo "Unsupported CPU architecture: $(uname -m)"; exit 1 ;;
esac
export __architecture

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

PKG_DOCKER_IMAGE="${PKG_DOCKER_IMAGE:-reactor}"

#-------------------------------------------------------------------------------

echo "Logging into DockerHub"
echo "$PKG_DOCKER_PASSWORD" | docker login --username "$PKG_DOCKER_USER" --password-stdin

REACTOR_PARENT_IMAGE="${REACTOR_PARENT_IMAGE:-"ubuntu:24.04"}"
REACTOR_TAG="$VERSION-${__architecture}"

if [ "$RUNTIME" != "standard" ]; then
  REACTOR_TAG="${RUNTIME}-${REACTOR_TAG}"

  if [ "$RUNTIME" != "nvidia" ]; then
    echo "Reactor Docker runtime not supported: ${RUNTIME}"
    exit 1
  fi
fi

echo "Building Docker image: ${REACTOR_TAG}"
docker build --force-rm --no-cache \
  --file "${__reactor_docker_dir}/Dockerfile" \
  --tag "${PKG_DOCKER_IMAGE}:${REACTOR_TAG}" \
  --platform "linux/${__architecture}" \
  --build-arg REACTOR_PARENT_IMAGE \
  --build-arg REACTOR_USER_UID \
  --build-arg REACTOR_USER_PASSWORD \
  "${__reactor_dir}"

echo "Pushing ${__architecture} Docker image: ${REACTOR_TAG}"
docker push "${PKG_DOCKER_IMAGE}:${REACTOR_TAG}"
