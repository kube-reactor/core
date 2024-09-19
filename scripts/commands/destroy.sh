#
#=========================================================================================
# <Destroy> Command
#

function destroy_description () {
  echo "Shut down and destroy Minikube development environment (DESTRUCTIVE)"
}
function destroy_usage () {
    cat <<EOF >&2

$(destroy_description)

Usage:

  kubectl reactor destroy [flags] [options]

Flags:
${__reactor_core_flags}

    --force               Force execution without confirming

EOF
  exit 1
}
function destroy_environment () {
  COMMAND_ARGUMENTS=("$@")
  set -- "${COMMAND_ARGUMENTS[@]}"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --force)
      FORCE=1
      ;;
      -h|--help)
      destroy_usage
      ;;
      *)
      if ! [ -z "$1" ]; then
        error "Unknown argument: ${1}"
        destroy_usage
      fi
      ;;
    esac
    shift
  done
  export FORCE=${FORCE:-0}

  debug "Command: destroy"
  debug "> FORCE: ${FORCE}"
}

function destroy_command () {
  destroy_environment "$@"

  if [ $FORCE -eq 0 ]; then
    confirm
  fi

  destroy_minikube
  remove_dns_records
  clean_terraform
  clean_helm
  clean_argocd
}

function destroy_host_command () {
  destroy_environment "$@"

  destroy_host_minikube
  remove_host_dns_records

  info "Minikube development environment has been destroyed"
}
