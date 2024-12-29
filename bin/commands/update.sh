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

  UPDATE_ALL="1"
  if [ "$UPDATE_APPS" -o "$UPDATE_DNS" -o "$UPDATE_CHARTS" ]; then
    UPDATE_ALL=""
  fi
  export UPDATE_ALL

  debug "> UPDATE_ALL: ${UPDATE_ALL}"
}

function update_command () {
  if [ "$UPDATE_ALL" -o "$UPDATE_APPS" ]; then
    provision_terraform
  fi
  run_hook update
}

function update_host_command () {
  launch_host_kubernetes_tunnel

  if [ "$UPDATE_ALL" -o "$UPDATE_DNS" ]; then
    create_host_dns_records
    save_host_dns_records
  fi
  if [ "$UPDATE_ALL" -o "$UPDATE_CHARTS" ]; then
    sync_argocd_charts
  fi

  run_hook update_host
  info "Kubernetes environment has been updated"
}
