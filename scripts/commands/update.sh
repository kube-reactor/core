#
#=========================================================================================
# <Update> Command
#

function update_description () {
  echo "Update the application stack in the Minikube environment"
}
function update_usage () {
    cat <<EOF >&2

$(update_description)

Usage:

  kubectl reactor update [flags] [options]

Flags:
${__reactor_core_flags}

    --apps                Provision any ArgoCD application updates
    --dns                 Update local DNS with service endpoints
    --charts              Sync local charts to ArgoCD application

EOF
  exit 1
}

function update_environment () {
  COMMAND_ARGUMENTS=("$@")
  set -- "${COMMAND_ARGUMENTS[@]}"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --apps)
      UPDATE_APPS=1
      ;;
      --dns)
      UPDATE_DNS=1
      ;;
      --charts)
      UPDATE_CHARTS=1
      ;;
      -h|--help)
      update_usage
      ;;
      *)
      if ! [ -z "$1" ]; then
        error "Unknown argument: ${1}"
        update_usage
      fi
      ;;
    esac
    shift
  done
  export UPDATE_APPS=${UPDATE_APPS:-0}
  export UPDATE_DNS=${UPDATE_DNS:-0}
  export UPDATE_CHARTS=${UPDATE_CHARTS:-0}

  UPDATE_ALL=1
  if [ $UPDATE_APPS -eq 1 -o $UPDATE_DNS -eq 1 -o $UPDATE_CHARTS -eq 1 ]; then
    UPDATE_ALL=0
  fi
  export UPDATE_ALL

  debug "Command: update"
  debug "> UPDATE_APPS: ${UPDATE_APPS}"
  debug "> UPDATE_DNS: ${UPDATE_DNS}"
  debug "> UPDATE_CHARTS: ${UPDATE_CHARTS}"
  debug "> UPDATE_ALL: ${UPDATE_ALL}"
}

function update_command () {
  update_environment "$@"

  if [ $UPDATE_ALL -eq 1 -o $UPDATE_APPS -eq 1 ]; then
    provision_terraform
  fi
  exec_hook update
}

function update_host_command () {
  update_environment "$@"

  if [ $UPDATE_ALL -eq 1 -o $UPDATE_DNS -eq 1 ]; then
    create_host_dns_records
    save_host_dns_records
  fi
  if [ $UPDATE_ALL -eq 1 -o $UPDATE_CHARTS -eq 1 ]; then
    sync_argocd_charts
  fi

  exec_hook update_host
  info "Minikube development environment has been updated"
}
