#
#=========================================================================================
# <Update> Command
#

function update_description () {
  render "Update the application stack in the Kubernetes environment"
}

function update_command_environment () {
  parse_flag --apps \
    UPDATE_APPS \
    "Provision any ArgoCD application updates"

  parse_flag --dns \
    UPDATE_DNS \
    "Update local DNS with service endpoints"

  parse_flag --charts \
    UPDATE_CHARTS \
    "Sync local charts to ArgoCD application"

  parse_flag --hooks \
    HOOKS \
    "Run all hooks defined"

  parse_flag --no-hooks \
    NO_HOOKS \
    "Disable the execution of update hooks for this update"

  UPDATE_ALL="1"
  if [ "$UPDATE_APPS" -o "$UPDATE_DNS" -o "$UPDATE_CHARTS" -o "$HOOKS" ]; then
    UPDATE_ALL=""
  fi
  export UPDATE_ALL

  debug "> UPDATE_ALL: ${UPDATE_ALL}"
}

function update_command () {
  if [ "$UPDATE_ALL" -o "$UPDATE_APPS" ]; then
    provision_kubernetes_applications
  fi

  launch_kubernetes_tunnel

  if [ "$UPDATE_ALL" -o "$UPDATE_DNS" ]; then
    if [ "$UPDATE_ALL" ]; then
      sleep 30
    fi
    save_dns_records
  fi
  if [ "$UPDATE_ALL" -o "$UPDATE_CHARTS" ]; then
    if [ "${__environment}" == "local" ]; then
      sync_argocd_charts
    fi
  fi

  if [ "$HOOKS" -o ! "$NO_HOOKS" ]; then
    run_hook update
  fi
  info "Kubernetes environment has been updated"
}
