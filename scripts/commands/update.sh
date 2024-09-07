#
#=========================================================================================
# <Update> Command
#

function update_usage () {
    cat <<EOF >&2

Update the application stack in the Minikube environment.

Usage:

  kubectl reactor update [flags] [options]

Flags:
${__reactor_core_flags}

    --apps                Provision any ArgoCD application updates
    --dns                 Update local DNS with service endpoints
    --chart               Sync local charts to ArgoCD application

EOF
  exit 1
}
function update_command () {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --apps)
      UPDATE_APPS=1
      ;;
      --dns)
      UPDATE_DNS=1
      ;;
      --chart)
      UPDATE_CHART=1
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
  UPDATE_APPS=${UPDATE_APPS:-0}
  UPDATE_DNS=${UPDATE_DNS:-0}
  UPDATE_CHART=${UPDATE_CHART:-0}
  UPDATE_ALL=1

  if [ $UPDATE_APPS -eq 1 -o $UPDATE_DNS -eq 1 -o $UPDATE_CHART -eq 1 ]; then
    UPDATE_ALL=0
  fi

  debug "Command: update"
  debug "> UPDATE_APPS: ${UPDATE_APPS}"
  debug "> UPDATE_DNS: ${UPDATE_DNS}"
  debug "> UPDATE_CHART: ${UPDATE_CHART}"
  debug "> UPDATE_ALL: ${UPDATE_ALL}"

  if [ $UPDATE_ALL -eq 1 -o $UPDATE_APPS -eq 1 ]; then
    provision_terraform
  fi
  if [ $UPDATE_ALL -eq 1 -o $UPDATE_DNS -eq 1 ]; then
    save_dns_records
  fi
  # if [ $UPDATE_ALL -eq 1 -o $UPDATE_CHART -eq 1 ]; then
  #   sync_argocd_charts
  # fi
  info "Minikube development environment has been updated"
}
