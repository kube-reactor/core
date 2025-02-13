#
#=========================================================================================
# Project bootstrap functions
#

function run_local () {
  if kubernetes_status; then
    add_docker_environment
  fi
  "${__bin_dir}/core/exec" "${__app_args[@]}"
}

function run_docker () {
  if [[ "$__os" == "darwin" ]]; then
    REACTOR_DOCKER_SOCKET_FILE="${REACTOR_DOCKER_SOCKET_FILE:-/var/run/docker.sock.raw}"
    if [ ! -e "$REACTOR_DOCKER_SOCKET_FILE" ]; then
      REACTOR_DOCKER_SOCKET_FILE="/var/run/docker.sock"
    fi
  else
    REACTOR_DOCKER_SOCKET_FILE="${REACTOR_DOCKER_SOCKET_FILE:-/var/run/docker.sock}"
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

#
#=========================================================================================
# Initialization functions
#

function mark_setup_complete () {
  touch "${__reactor_dir}/.initialized"
}

function is_setup_complete () {
  if [ -f "${__reactor_dir}/.initialized" ]; then
    return 0
  else
    return 1
  fi
}

function set_initialized () {
  export INITIALIZED="1"
}

function is_initialized () {
  if [ "$INITIALIZED" ]; then
    return 0
  else
    return 1
  fi
}

#
#=========================================================================================
# Manifest functions
#

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

function check_core () {
  if [ ! "${__core_manifest}" ]; then
    return 1
  else
    return 0
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

function check_template () {
  if [ ! "${__template_manifest}" ]; then
    return 1
  else
    return 0
  fi
}

function init_template () {
  export __template_dir="$(dirname "$1")"
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

function check_project () {
  if [ ! "${__project_manifest}" ]; then
    return 1
  else
    return 0
  fi
}

function init_project() {
  export __project_dir="$(dirname "$1")"
  export __env_dir="${__project_dir}/env/${__environment}"
  export __init_file="${__env_dir}/.initialized"

  export __project_reactor_dir="${__project_dir}/reactor"
  export __project_utilities_dir="${__project_reactor_dir}/utilities"
  export __project_test_dir="${__project_reactor_dir}/tests"

  export __app_dir="${__project_dir}/projects"
  export __certs_dir="${__project_dir}/certs"
  export __cache_dir="${__project_dir}/cache"
  export __log_dir="${__project_dir}/logs"

  export __docker_dir="${__project_dir}/docker"
  export __charts_dir="${__project_dir}/charts"
  export __extension_dir="${__project_dir}/extensions"

  export __terraform_dir="${__project_dir}/terraform"
  export __argocd_apps_dir="${__terraform_dir}/argocd-apps"

  export __project_name="$(config short_name)"

  # Load environment configuration
  if [ -f "${__env_dir}/public.sh" ]; then
    source "${__env_dir}/public.sh"
  fi

  if [[ ! -f "${__env_dir}/secret.sh" ]] && [[ -f "${__env_dir}/secret.example.sh" ]]; then 
    cp -f "${__env_dir}/secret.example.sh" "${__env_dir}/secret.sh"
  fi
  if [ -f "${__env_dir}/secret.sh" ]; then
    source "${__env_dir}/secret.sh"
  fi

  export APP_NAME="${__project_name//_/-}"
  export APP_LABEL="$(config name)"

  export PRIMARY_DOMAIN="$(config "domain.${__environment}" "$(echo "$APP_NAME" | tr '_' '-').local")"
  export PROJECT_UPDATE_WAIT="${PROJECT_UPDATE_WAIT:-"30s"}"

  export ARGOCD_DOMAIN="${ARGOCD_DOMAIN:-"argocd.${PRIMARY_DOMAIN}"}"
}

function requires_project () {
  local command="$1"
  local check_function="${command}_requires_project"

  if [[ "$command" =~ ^- ]]; then
    # No valid command specifed so pass back to parent as normal
    return 0
  fi

  if function_exists "$check_function"; then
    # Farm it off to a command level processor (create and test ...)
    "$check_function"
    return $?
  else
    # All commands by default run in containers before host execution
    return 0
  fi
}

function warn_no_project () {
  local command="${1:--}"

  if ! check_project && requires_project "$command"; then
    # Display error message (no project)
    add_space
    error "Project directory with a 'reactor.yml' file does not exist in current or parent directories (set project name with REACTOR_PROJECT_NAME)"
    add_space
  fi
}

#
#=========================================================================================
# Configuration Lookup functions
#

function config () {
  "${__bin_dir}/utilities/locator.py" "$1" "${2-}"
}

function env_json () {
  "${__bin_dir}/utilities/env_json.py"
}

#
#=========================================================================================
# Installation and Execution functions
#

function function_exists () {
  debug "Checking function: ${1}"
  declare -F "$1" > /dev/null;
}

function check_binary () {
  if ! command -v "$1" > /dev/null; then
    emergency "Install binary: \"$1\""
  fi
}

function download_binary () {
  if ! command -v "$3/$1" > /dev/null; then
    debug "Download binary: \"$1\" from url: \"$2\""
    if [[ "$2" == *.tar.gz ]]; then
      curl -sLo "/tmp/$1.tar.gz" "$2" 1>>"$(logfile)" 2>&1
      tar -xzf "/tmp/$1.tar.gz" -C "/tmp" 1>>"$(logfile)" 2>&1
      mv "/tmp/$4/$1" "/tmp/$1" 1>>"$(logfile)" 2>&1
      rm -f "/tmp/$1.tar.gz" 1>>"$(logfile)" 2>&1
      rm -Rf "/tmp/$4" 1>>"$(logfile)" 2>&1
    else
      curl -sLo "/tmp/$1" "$2" 1>>"$(logfile)" 2>&1
    fi
    install "/tmp/$1" "$3" 1>>"$(logfile)" 2>&1
    rm -f "/tmp/$1" 1>>"$(logfile)" 2>&1
    debug "\"$1\" was downloaded install binary into folder: \"$3\""
  fi
}

#
#=========================================================================================
# Logging functions
#

function logdir () {
  if check_project && [[ "${__log_dir:-}" ]]; then
    echo "${__log_dir}"
  else
    echo "/tmp"
  fi
}

function logfile () {
    echo "$(logdir)/reactor.log"
}
