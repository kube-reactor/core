#
#=========================================================================================
# Docker Utilities
#

function add_container_environment () {
  run_kube_function add_container_environment
}

function delete_container_environment () {
  unset DOCKER_TLS_VERIFY
  unset DOCKER_HOST
  unset DOCKER_CERT_PATH
  unset MINIKUBE_ACTIVE_DOCKERD

  run_kube_function delete_container_environment
}


function build_docker_image () {
  cert_environment

  PROJECT_NAME="${1}"
  PROJECT_DIR="${2}"
  NO_CACHE="${3:-}"

  DOCKER_DIR="${PROJECT_DIR}/$(config docker.$PROJECT_NAME.directory docker)"
  DOCKER_FILE="${DOCKER_DIR}/$(config docker.$PROJECT_NAME.file Dockerfile)"

  if [ -f "$DOCKER_FILE" ]; then
    BUILD_SCRIPT_NAME="$(config docker.$PROJECT_NAME.args build_image)"
    BUILD_SCRIPT="${PROJECT_DIR}/reactor/${BUILD_SCRIPT_NAME}.sh"
    PROJECT_BUILD_SCRIPT="${__project_reactor_dir}/docker/${BUILD_SCRIPT_NAME}.${PROJECT_NAME}.sh"
    DOCKER_BUILD_VARS=()

    debug "Function: build_image"
    debug "> PROJECT_NAME: ${PROJECT_NAME}"
    debug "> PROJECT_DIR: ${PROJECT_DIR}"
    debug "> DOCKER_DIR: ${DOCKER_DIR}"
    debug "> DOCKER_FILE: ${DOCKER_FILE}"
    debug "> BUILD_SCRIPT: ${BUILD_SCRIPT}"
    debug "> PROJECT_BUILD_SCRIPT: ${PROJECT_BUILD_SCRIPT}"
    debug "> NO_CACHE: ${NO_CACHE}"

    if [ -f "$BUILD_SCRIPT" ]; then
      source "$BUILD_SCRIPT" "$NO_CACHE"
    fi
    if [ -f "$PROJECT_BUILD_SCRIPT" ]; then
      source "$PROJECT_BUILD_SCRIPT" "$NO_CACHE"
    fi

    DOCKER_ARGS=(
      "--file" "${DOCKER_FILE}"
      "--tag" "${PROJECT_NAME}:$(config docker.$PROJECT_NAME.tag dev)"
      "--platform" "linux/${__architecture}"
    )
    if [ "$NO_CACHE" ]; then
      DOCKER_ARGS=("${DOCKER_ARGS[@]}" "--no-cache" "--force-rm")
    fi

    for build_var in "${DOCKER_BUILD_VARS[@]}"
    do
      DOCKER_ARGS=("${DOCKER_ARGS[@]}" "--build-arg" "$build_var")
    done
    DOCKER_ARGS=("${DOCKER_ARGS[@]}" "${PROJECT_DIR}")

    debug "Docker build arguments"
    debug "${DOCKER_ARGS[@]}"
    docker build "${DOCKER_ARGS[@]}" 1>>"$(logfile)" 2>&1
  else
    debug "No Dockerfile for project ${PROJECT_NAME} in ${PROJECT_DIR}"
  fi
}


function wipe_docker () {
  info "Stopping and removing all Docker containers ..."
  CONTAINERS=$(docker ps -aq)

  if [ ! -z "$CONTAINERS" ]; then
    docker stop $CONTAINERS >/dev/null 2>&1
    docker rm $CONTAINERS >/dev/null 2>&1
  fi

  info "Removing all Docker networks ..."
  docker network prune -f >/dev/null 2>&1

  info "Removing unused Docker images ..."
  IMAGES=$(docker images --filter dangling=true -qa)

  if [ ! -z "$IMAGES" ]; then
    docker rmi -f $IMAGES >/dev/null 2>&1
  fi

  info "Removing all Docker volumes ..."
  VOLUMES=$(docker volume ls --filter dangling=true -q)

  if [ ! -z "$VOLUMES" ]; then
    docker volume rm $VOLUMES >/dev/null 2>&1
  fi

  info "Cleaning up any remaining Docker images ..."
  IMAGES=$(docker images -qa)

  if [ ! -z "$IMAGES" ]; then
    docker rmi -f $IMAGES >/dev/null 2>&1
  fi

  info "Cleaning Docker build cache ..."
  docker system prune -a -f >/dev/null 2>&1
}
