#
#=========================================================================================
# Docker Utilities
#

function build_docker_image () {
  cert_environment

  PROJECT_NAME="${1}"
  NO_CACHE=${2:-0}

  PROJECT_DIR="${__docker_dir}/${PROJECT_NAME}"
  DOCKER_DIR="${PROJECT_DIR}/$(config docker.$PROJECT_NAME.docker_dir docker)"
  BUILD_SCRIPT="${PROJECT_DIR}/reactor/build_image.sh"
  PROJECT_BUILD_SCRIPT="${__project_reactor_dir}/docker/${PROJECT_NAME}_build_image.sh"
  DOCKER_FILE="Dockerfile"
  DOCKER_BUILD_VARS=()

  debug "Function: build_image"
  debug "> PROJECT_NAME: ${PROJECT_NAME}"
  debug "> PROJECT_DIR: ${PROJECT_DIR}"
  debug "> DOCKER_DIR: ${DOCKER_DIR}"
  debug "> BUILD_SCRIPT: ${BUILD_SCRIPT}"
  debug "> PROJECT_BUILD_SCRIPT: ${PROJECT_BUILD_SCRIPT}"
  debug "> NO_CACHE: ${NO_CACHE}"

  if [ -f "$BUILD_SCRIPT" ]; then
    source "$BUILD_SCRIPT" $NO_CACHE
  fi
  if [ -f "$PROJECT_BUILD_SCRIPT" ]; then
    source "$PROJECT_BUILD_SCRIPT" $NO_CACHE
  fi

  DOCKER_ARGS=(
    "--file" "${DOCKER_DIR}/${DOCKER_FILE}"
    "--tag" "${PROJECT_NAME}:$(config docker.$PROJECT_NAME.docker_tag dev)"
    "--platform" "linux/${__architecture}"
  )
  if [ $NO_CACHE -eq 1 ]; then
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
