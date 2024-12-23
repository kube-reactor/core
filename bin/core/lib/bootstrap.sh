#
#=========================================================================================
# Project bootstrap functions
#

function run_local () {
  "${__bin_dir}/core/exec" "${__app_args[@]}"
}

function run_docker () {
  if [[ "$__os" == "darwin" ]]; then
    REACTOR_DOCKER_SOCKET_FILE="${REACTOR_DOCKER_SOCKET_FILE:-/var/run/docker.sock.raw}"
    REACTOR_DOCKER_GROUP="0"
  else
    REACTOR_DOCKER_SOCKET_FILE="${REACTOR_DOCKER_SOCKET_FILE:-/var/run/docker.sock}"
    REACTOR_DOCKER_GROUP="$(stat -L -c '%g' /var/run/docker.sock)"
  fi
  export REACTOR_DOCKER_SOCKET_FILE
  export REACTOR_RUNTIME_IMAGE="${REACTOR_RUNTIME_IMAGE:-"${APP_NAME}:${__reactor_version}"}"

  if [ -z ${REACTOR_DOCKER_RUN_ARGS+x} ]; then
    export REACTOR_DOCKER_RUN_ARGS=()
  fi

  REACTOR_ARGS=(
    "--rm"
    "--interactive"
    "--tty"
    "--network" "host"
    "--volume" "${REACTOR_DOCKER_SOCKET_FILE}:/var/run/docker.sock"
    "--volume" "${__reactor_dir}:/reactor"
    "--volume" "${__project_dir}:${__project_dir}"
    "--workdir" "${__project_dir}"
    "--env" "__script_name=${__script_name}"
  )

  ENVIRONMENT="$(current_environment)"
  for variable in ${ENVIRONMENT[@]}; do
    REACTOR_ARGS=("${REACTOR_ARGS[@]}" "--env" "$variable")
  done

  for share_dir_name in ${HOME_SHARES[@]}; do
    if [ -e "${__home_dir}/${share_dir_name}" ]; then
      REACTOR_ARGS=("${REACTOR_ARGS[@]}" "--volume" "${__home_dir}/${share_dir_name}:${__home_dir}/${share_dir_name}")
    fi
  done

  if ! docker inspect "$REACTOR_RUNTIME_IMAGE" >/dev/null 2>&1; then
    debug "Building local virtualization container"
    "${__bin_dir}/core/image"
    REACTOR_RUNTIME_IMAGE="${APP_NAME}:${__reactor_version}"
  fi
  REACTOR_ARGS=(
    "${REACTOR_ARGS[@]}"
    "${REACTOR_DOCKER_RUN_ARGS[@]}"
    "$REACTOR_RUNTIME_IMAGE"
  )

  debug "======================================"
  debug "Reactor Arguments: ${REACTOR_ARGS[@]}"
  debug "======================================"

  if [ ${#__app_args[@]} -gt 0 ]; then
    debug "__app_args: ${__app_args[@]}"

    if [ "${__app_args[0]}" == "enter" ]; then
      info "Entering reactor environment ..."
      docker run --entrypoint bash "${REACTOR_ARGS[@]}"
      exit
    fi
  fi

  # Containerized execution (primary command logic)
  debug "Running reactor command ..."
  docker run "${REACTOR_ARGS[@]}" "${__app_args[@]}"
}


function core_manifest () {
  krew_manifest_template="${1}/reactor.template.yaml"

  if [ -f "$krew_manifest_template" ]; then
    echo "$krew_manifest_template"
    return
  fi

  parent_dir="$(dirname $1)"
  if [ "$parent_dir" = "/" ]; then
    echo ""
  else
    core_manifest "$parent_dir"
  fi
}

function template_manifest () {
  cookiecutter_manifest="${1}/cookiecutter.json"

  if [ -f "$cookiecutter_manifest" ]; then
    echo "$cookiecutter_manifest"
    return
  fi

  parent_dir="$(dirname $1)"
  if [ "$parent_dir" = "/" ]; then
    echo ""
  else
    template_manifest "$parent_dir"
  fi
}

function project_manifest () {
  project_manifest="${1}/reactor.yml"

  if [ -f "$project_manifest" ]; then
    echo "$project_manifest"
    return
  fi

  parent_dir="$(dirname $1)"
  if [ "$parent_dir" = "/" ]; then
    echo ""
  else
    project_manifest "$parent_dir"
  fi
}


function config () {
  "${__bin_dir}/utilities/locator.py" "$1" "${2-}"
}

function env_json () {
  "${__bin_dir}/utilities/env_json.py"
}

function function_exists () {
  debug "Checking function: ${1}"
  declare -F "$1" > /dev/null;
}
