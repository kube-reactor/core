#
#=========================================================================================
# <Update> Command
#

function update_description () {
  render "Update the application stack in the Kubernetes environment"
}

function update_command_environment () {
  if [[ "${REACTOR_TEST_PROVISIONER_STATE:-}" ]] && [[ "${STATE_PROVIDER:-}" ]]; then
    parse_flag --state \
      UPDATE_STATE \
      "Update the provisioner state project if it exists (NOT run by default)"

    parse_flag --state-rm \
      REMOVE_STATE \
      "Remove the provisioner state project if it exists (NOT run by default)"
  fi

  parse_flag --apps \
    UPDATE_APPS \
    "Provision any ArgoCD application updates (run by default)"

  parse_flag --dns \
    UPDATE_DNS \
    "Update local DNS with service endpoints (run by default)"

  parse_flag --charts \
    UPDATE_CHARTS \
    "Sync local charts to ArgoCD application (run by default)"

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
  save_libraries

  if [[ "${REACTOR_TEST_PROVISIONER_STATE:-}" ]] && [[ "${STATE_PROVIDER:-}" ]]; then
    if [ "$UPDATE_STATE" ]; then
      export REACTOR_FORCE_STATE_UPDATE="true"
      ensure_remote_state
      unset REACTOR_FORCE_STATE_UPDATE
      info "Remote state has been successfully updated."
      exit 0

    elif [ "$REMOVE_STATE" ]; then
      export REACTOR_FORCE_STATE_UPDATE="true"
      destroy_remote_state
      unset REACTOR_FORCE_STATE_UPDATE
      info "Remote state has been successfully removed."
      exit 0
    fi
  fi

  if [ "$UPDATE_ALL" -o "$UPDATE_APPS" ]; then
    provision_kubernetes_applications
  fi

  launch_kubernetes_tunnel

  if [ "$UPDATE_ALL" -o "$UPDATE_DNS" ]; then
    if [ "$UPDATE_ALL" ]; then
      sleep 60
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
