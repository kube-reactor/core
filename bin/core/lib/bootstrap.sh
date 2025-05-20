#
#=========================================================================================
# Project bootstrap functions
#

function run_local () {
  echo "" >"$(logfile)"
  debug "====================================================================="
  debug "Command: ${__app_args[@]}"
  debug "====================================================================="
  debug ""

  debug "Environment Variables"
  debug "======================================"
  debug "$(render_environment)"
  debug ""
  #
  #=========================================================================================
  # Execution
  #
  if [[ "$arg_h" ]] || [[ ${#__app_args[@]} -eq 0 ]]; then
    if [[ ${#__app_args[@]} -gt 0 ]] && [[ "${__app_args[0]}" =~ ^[^-] ]]; then
      if function_exists "${__app_args[0]}_description"; then
        "${__app_args[0]}_description" >/dev/null 2>&1
        if [ -z "${PASSTHROUGH:-}" ]; then
          generate_command_help "${__app_args[0]}"
        fi
      fi
    else
      gateway_usage
    fi
  fi

  COMMAND="${__app_args[0]}"
  COMMAND_ARGS=("${__app_args[@]:1}")

  warn_no_project "${COMMAND}"

  if [ "$COMMAND" == "help" ]; then
    if [[ ${#COMMAND_ARGS[@]} -eq 0 ]]; then
      gateway_usage
    else
      generate_command_help "${COMMAND_ARGS[0]}"
    fi
  fi

  if kubernetes_status; then
    add_container_environment
  fi

  pop_arg_command
  run_command "$COMMAND" command "${COMMAND_ARGS[@]}"
  run_hook finalize
}

function run_docker () {
  delete_container_environment

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
    "--tty"
    "--interactive"
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
    "${__bin_dir}/core/image.sh"
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
  if check_project; then
    local project="$(basename "$(dirname "${__project_manifest}")")"
    touch "${HOME}/.reactor/initialized_${project}"
  else
    touch "${HOME}/.reactor/initialized"
  fi
}

function is_setup_complete () {
  if check_project; then
    local project="$(basename "$(dirname "${__project_manifest}")")"
    if [ -f "${HOME}/.reactor/initialized_${project}" ]; then
      return 0
    fi
  else
    if [ -f "${HOME}/.reactor/initialized" ]; then
      return 0
    fi
  fi
  return 1
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

function check_dependencies () {
  check_binary docker 1>>"$(logfile)" 2>&1
  check_binary git 1>>"$(logfile)" 2>&1
}


function install_os_requirements () {
  if check_project; then
    if [ -f "${__project_dir}/reactor/install.sh" ]; then
      unset "install_${__os_type}"
      unset "install_${__os_dist}"

      source "${__project_dir}/reactor/install.sh"

      if function_exists "install_${__os_type}"; then
        "install_${__os_type}"
      fi
      if [[ "${__os_type}" != "${__os_dist}" ]] && function_exists "install_${__os_dist}"; then
        "install_${__os_dist}"
      fi
    fi

    if [ "${__environment}" == "local" ]; then
      for docker in $(config docker); do
        docker_dir="${__docker_dir}/$(config docker.docker.project $docker)"

        if [ -f "${docker_dir}/reactor/install.sh" ]; then
          unset "install_${__os_type}"
          unset "install_${__os_dist}"

          source "${docker_dir}/reactor/install.sh"

          if function_exists "install_${__os_type}"; then
            "install_${__os_type}"
          fi
          if [[ "${__os_type}" != "${__os_dist}" ]] && function_exists "install_${__os_dist}"; then
            "install_${__os_dist}"
          fi
        fi
      done

      for chart in $(config charts); do
        chart_dir="${__charts_dir}/$(config charts.$chart.project $chart)"

        if [ -f "${chart_dir}/reactor/install.sh" ]; then
          unset "install_${__os_type}"
          unset "install_${__os_dist}"

          source "${chart_dir}/reactor/install.sh"

          if function_exists "install_${__os_type}"; then
            "install_${__os_type}"
          fi
          if [[ "${__os_type}" != "${__os_dist}" ]] && function_exists "install_${__os_dist}"; then
            "install_${__os_dist}"
          fi
        fi
      done
    fi

    for extension in $(config extensions); do
      extension_dir="${__extension_dir}/${extension}"

      if [ -f "${extension_dir}/reactor/install.sh" ]; then
        unset "install_${__os_type}"
        unset "install_${__os_dist}"

        source "${extension_dir}/reactor/install.sh"

        if function_exists "install_${__os_type}"; then
          "install_${__os_type}"
        fi
        if [[ "${__os_type}" != "${__os_dist}" ]] && function_exists "install_${__os_dist}"; then
          "install_${__os_dist}"
        fi
      fi
    done
  elif [ -d "${__exec_reactor_dir}" ]; then
    if [ -f "${__exec_reactor_dir}/install.sh" ]; then
      unset "install_${__os_type}"
      unset "install_${__os_dist}"

      source "${__exec_reactor_dir}/install.sh"

      if function_exists "install_${__os_type}"; then
        "install_${__os_type}"
      fi
      if [[ "${__os_type}" != "${__os_dist}" ]] && function_exists "install_${__os_dist}"; then
        "install_${__os_dist}"
      fi
    fi
  fi
}

function install_python_requirements () {
  if check_project; then
    if [ -f "${__project_dir}/reactor/requirements.txt" ]; then
      pip3 install --no-cache-dir -r "${__project_dir}/reactor/requirements.txt"
    fi

    if [ "${__environment}" == "local" ]; then
      for docker in $(config docker); do
        docker_dir="${__docker_dir}/$(config docker.docker.project $docker)"
        if [ -f "${docker_dir}/reactor/requirements.txt" ]; then
          pip3 install --no-cache-dir -r "${docker_dir}/reactor/requirements.txt"
        fi
      done

      for chart in $(config charts); do
        chart_dir="${__charts_dir}/$(config charts.$chart.project $chart)"
        if [ -f "${chart_dir}/reactor/requirements.txt" ]; then
          pip3 install --no-cache-dir -r "${chart_dir}/reactor/requirements.txt"
        fi
      done
    fi

    for extension in $(config extensions); do
      extension_dir="${__extension_dir}/${extension}"
      if [ -f "${extension_dir}/reactor/requirements.txt" ]; then
        pip3 install --no-cache-dir -r "${extension_dir}/reactor/requirements.txt"
      fi
    done
  elif [ -d "${__exec_reactor_dir}" ]; then
    if [ -f "${__exec_reactor_dir}/requirements.txt" ]; then
      pip3 install --no-cache-dir -r "${__exec_reactor_dir}/requirements.txt"
    fi
  fi
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
  export __env_lib_dir="${__project_dir}/env"
  export __env_dir="${__env_lib_dir}/${__environment}"
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
  export __library_file="${HOME}/.reactor/libraries_${__project_name}"

  export APP_NAME="${__project_name//_/-}"
  export APP_LABEL="$(config name)"

  export PRIMARY_DOMAIN="$(config "domain.${__environment}" "$(echo "$APP_NAME" | tr '_' '-').local")"
  export PROJECT_UPDATE_WAIT="${PROJECT_UPDATE_WAIT:-"30s"}"

  export ARGOCD_DOMAIN="${ARGOCD_DOMAIN:-"argocd.${PRIMARY_DOMAIN}"}"

  # Load environment configuration
  if [ -f "${__env_dir}/public.sh" ]; then
    source "${__env_dir}/public.sh"
  fi

  if [[ "${__environment}" == "local" ]] && [[ ! -f "${__env_dir}/secret.sh" ]] && [[ -f "${__env_dir}/secret.example.sh" ]]; then
    cp -f "${__env_dir}/secret.example.sh" "${__env_dir}/secret.sh"
  fi
  if [ -f "${__env_dir}/secret.sh" ]; then
    source "${__env_dir}/secret.sh"
  fi
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
# Project manifest generation functions
#

function add_docker_project () {
  local project_name="$1"
  local remote_url="$2"
  local reference="${3:-main}"
  local docker_dir="${4:-docker}"
  local docker_tag="${5:-dev}"

  "${__bin_dir}/utilities/add_docker.py" \
    "$project_name" \
    "$remote_url" \
    "$reference" \
    "$docker_dir" \
    "$docker_tag"
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
    mkdir -p "${__log_dir}"
    echo "${__log_dir}"
  else
    echo "/tmp"
  fi
}

function logfile () {
  if [ "${REACTOR_SHELL_OUTPUT:-}" ]; then
    echo "/dev/stdout"
  else
    echo "$(logdir)/reactor.log"
  fi
}
