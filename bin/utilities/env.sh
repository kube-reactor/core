#
#=========================================================================================
# Command Environment Utilities
#
source "${__utilities_dir}/hooks.sh"


function render_overview () {
  debug ""
  debug "Script properties"
  debug "======================================"
  debug "> Local execution: ${REACTOR_LOCAL:-0}"
  debug "> OS type: ${OSTYPE:-}"
  debug "> OS name: ${__os:-}"
  debug "> CPU arch: ${__architecture:-}"
  debug "> Invocation: ${__reactor_invocation:-}"
  debug "> Reactor directory: ${__reactor_dir:-}"
  debug "> Script directory: ${__script_dir:-}"
  debug ""

  debug "Project and development properties"
  debug "======================================"
  debug "> Project directory: ${__project_dir:-}"
  debug "> Project manifest: ${__project_file:-}"
  debug "> Certificate directory: ${__certs_dir:-}"
  debug "> Executable directory: ${__binary_dir:-}"
  debug "> Docker image project root directory: ${__docker_dir:-}"
  debug "> Helm chart project root directory: ${__charts_dir:-}"
  debug "> Terraform project root directory: ${__terraform_dir:-}"
  debug ""

  run_hook render_overview
}

function current_environment () {
  ENVIRONMENT_VARS=()

  while IFS= read -r variable; do
    if [[ "$variable" != "HOSTNAME" ]] \
      && [[ "$variable" != "PATH" ]] \
      && [[ "$variable" != "PWD" ]] \
      && [[ "$variable" != "USER" ]] \
      && [[ "$variable" != "HOME" ]] \
      && [[ "$variable" != "SHELL" ]] \
      && [[ "$variable" != "BASH_"* ]]; then

      ENVIRONMENT_VARS=("${ENVIRONMENT_VARS[@]}" "$variable")
    fi
  done <<< "$(env | grep -Po "[_A-Z0-9]{3,}=" | sed 's/\=//')"

  echo "${ENVIRONMENT_VARS[@]}"
}

function render_environment () {
  for variable in $(current_environment); do
    if [[ "$variable" != "COLOR_"* ]]; then
      echo "${variable}: $(eval "echo \"\$${variable}\"" 2>/dev/null)"
    fi
  done
}

function parse_environment () {
  local command="$1"
  local environment_function="${command}_command_environment"

  if function_exists "$environment_function"; then
    "$environment_function"
  fi
  if [ "${__reactor_arg_errors}" ]; then
    command_usage "$command"
    render_overview
    exit 1
  fi
  render_overview
}