#!/usr/bin/env bash
#
# Usage:
#
#  "${__bin_dir}/core/image.sh" "$OPERATING_SYSTEM"
#
#=========================================================================================
# Initialization
#
set -e

# Initialize top level directories and load bootstrap functions
SCRIPT_PATH="${BASH_SOURCE[0]}"

export __script_name="reactor reimage"
export __core_dir="$(cd "$(dirname "${SCRIPT_PATH}")" && pwd)"
export __bin_dir="$(dirname "${__core_dir}")"
export __reactor_dir="$(dirname "${__bin_dir}")"
export __reactor_docker_dir="${__reactor_dir}/docker"

source "${__core_dir}/loader.sh"

#=========================================================================================
# Parameter processing
#
HELP="Regenerate the local project Reactor virtualization container image"

function image_params () {
  image_build_options
}
parse_cli image_params "$@"

debug "Disable build cache: ${NO_CACHE}"

#========================================

if ! check_project; then
  add_space
  error "Active project required to build reactor Docker image."
  add_space
  exit 1
fi

export REACTOR_IMAGE="${REACTOR_IMAGE:-$APP_NAME}"
export REACTOR_TAG="${REACTOR_TAG:-"${__reactor_version}"}"

export REACTOR_PARENT_IMAGE="${REACTOR_PARENT_IMAGE:-"ubuntu:22.04"}"

if docker image inspect "${REACTOR_IMAGE}:${REACTOR_TAG}" 1>/dev/null 2>&1; then
  info "Removing existing Docker image: ${REACTOR_IMAGE}:${REACTOR_TAG}"
  docker image rm "${REACTOR_IMAGE}:${REACTOR_TAG}"
fi

info "Building Docker image: ${REACTOR_IMAGE}:${REACTOR_TAG}"
if [ -z ${REACTOR_DOCKER_BUILD_ARGS+x} ]; then
  export REACTOR_DOCKER_BUILD_ARGS=()
fi

REACTOR_ARGS=(
  "--force-rm"
  "--file" "${__reactor_docker_dir}/Dockerfile"
  "--tag" "${REACTOR_IMAGE}:${REACTOR_TAG}"
  "--platform" "linux/${__architecture}"
  "--build-arg" "REACTOR_PARENT_IMAGE"
  "--build-arg" "REACTOR_ARCHITECTURE=${__architecture}"
  "--build-arg" "REACTOR_USER_NAME=${__user_name}"
  "--build-arg" "REACTOR_USER_UID=${__user_id}"
  "--build-arg" "REACTOR_DOCKER_GID=${__docker_group_id}"
)

if [ "$NO_CACHE" ]; then
  REACTOR_ARGS=("${REACTOR_ARGS[@]}" "--no-cache")
fi

REACTOR_ARGS=(
  "${REACTOR_ARGS[@]}"
  "${REACTOR_DOCKER_BUILD_ARGS[@]}"
  "${__reactor_dir}"
)

debug "Reactor Arguments: ${REACTOR_ARGS[@]}"
docker build "${REACTOR_ARGS[@]}"
