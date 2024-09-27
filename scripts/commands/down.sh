#
#=========================================================================================
# <Down> Command
#

function down_description () {
  echo "Shut down but do not destroy development environment services"
}
function down_usage () {
    cat <<EOF >&2

$(down_description)

Usage:

  kubectl reactor down [flags] [options]

Flags:
${__reactor_core_flags}

EOF
  exit 1
}

function down_environment () {
  COMMAND_ARGUMENTS=("$@")
  set -- "${COMMAND_ARGUMENTS[@]}"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
      down_usage
      ;;
      *)
      if ! [ -z "$1" ]; then
        error "Unknown argument: ${1}"
        down_usage
      fi
      ;;
    esac
    shift
  done

  debug "Command: down"
}

function down_command () {
  down_environment "$@"

  stop_minikube
  remove_dns_records

  exec_hook down
}

function down_host_command () {
  down_environment "$@"

  stop_host_minikube
  remove_host_dns_records

  exec_hook down
  info "Minikube development environment has been shut down"
}
