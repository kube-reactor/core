#
#=========================================================================================
# <Clean> Command
#

function clean_description () {
  echo "Cleanup and wipe project resources (VERY DESTRUCTIVE)"
}
function clean_usage () {
    cat <<EOF >&2

$(clean_description)

Usage:

  kubectl reactor clean [flags] [options]

Flags:
${__reactor_core_flags}

    --force               Force execution without confirming

EOF
  exit 1
}

function clean_environment () {
  COMMAND_ARGUMENTS=("$@")
  set -- "${COMMAND_ARGUMENTS[@]}"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --force)
      FORCE=1
      ;;
      -h|--help)
      clean_usage
      ;;
      *)
      if ! [ -z "$1" ]; then
        error "Unknown argument: ${1}"
        clean_usage
      fi
      ;;
    esac
    shift
  done
  export FORCE=${FORCE:-0}

  debug "Command: clean"
  debug "> FORCE: ${FORCE}"
}

function clean_command () {
  clean_environment "$@"

  if [ $FORCE -eq 0 ]; then
    confirm
  fi

  destroy_minikube
  remove_dns_records

  clean_terraform
  clean_certs
  clean_cache
}

function clean_host_command () {
  clean_environment "$@"

  destroy_host_minikube
  remove_host_dns_records

  info "Reactor development environment has been cleaned"
}
