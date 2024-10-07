#
#=========================================================================================
# Command Argument Utilities
#

function reactor_args () {
  REACTOR_ARGUMENTS=("$@")
  set -- "${REACTOR_ARGUMENTS[@]}"

  COMMAND_ARGS=()

  arg_processed=0

  [[ $# -eq 0 ]] && arg_h=1

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --verbose)
        arg_v=1
        shift
        ;;
      --debug)
        arg_d=1
        shift
        ;;
      --no-color)
        arg_n=1
        shift
        ;;
      -h|--help)
        if [ $arg_processed -ne 1 ]; then
          arg_h=1
        else
          COMMAND_ARGS+=("$1")
        fi
        shift
        ;;
      *)
        COMMAND_ARGS+=("$1")
        arg_processed=1
        shift
        ;;
    esac
  done
  export arg_v
  export arg_d
  export arg_n
  export arg_h
  export COMMAND_ARGS

  # Error handling
  set -o errexit
  set -o errtrace
  set -o nounset
  set -o pipefail

  # Log check
  [[ "${LOG_LEVEL:-6}" ]] || emergency "Cannot continue without LOG_LEVEL"

  # Debug mode
  if [[ "${arg_d:-0}" = "1" ]]; then
    #set -o xtrace
    export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    export LOG_LEVEL="7"
    # Enable error backtracing
    trap '__err_report "${FUNCNAME:-.}" ${LINENO}' ERR
  fi

  # Verbose mode
  if [[ "${arg_v:-0}" = "1" ]]; then
    set -o verbose
  fi

  # No color mode
  if [[ "${arg_n:-0}" = "1" ]]; then
    export NO_COLOR="true"
  fi

  debug "Top level flags"
  debug "> Debug: ${arg_d:-0}"
  debug "> Verbosity: ${arg_v:-0}"
  debug "> Color: ${NO_COLOR:-}"
  debug "> Help: ${arg_h:-0}"

  debug "Script properties"
  debug "> Local execution: ${REACTOR_LOCAL}"
  debug "> OS type: ${OSTYPE}"
  debug "> OS name: ${__os}"
  debug "> CPU arch: ${__architecture}"
  debug "> Invocation: ${__reactor_invocation}"
  debug "> Reactor directory: ${__reactor_dir}"
  debug "> Script directory: ${__script_dir}"

  debug "Project and development properties"
  debug "> Project directory: ${__project_dir}"
  debug "> Project manifest: ${__project_file}"
  debug "> Certificate directory: ${__certs_dir}"
  debug "> Executable directory: ${__binary_dir}"
  debug "> Docker image project root directory: ${__docker_dir}"
  debug "> Helm chart project root directory: ${__charts_dir}"
  debug "> Terraform project root directory: ${__terraform_dir}"
}
