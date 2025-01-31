#
#=========================================================================================
# Provisioner Utilities
#

function provisioner_environment () {
  debug "Setting provisioner environment ..."
  export STATE_PROVIDER="${STATE_PROVIDER:-}"
  export PROVISIONER_PROVIDER="${PROVISIONER_PROVIDER:-terraform}"

  debug "STATE_PROVIDER: ${STATE_PROVIDER}"
  debug "PROVISIONER_PROVIDER: ${PROVISIONER_PROVIDER}"

  cert_environment
  kubernetes_environment
  helm_environment

  run_dns_function provisioner_environment
}


function run_state_function () {
  local base_name="$1"
  shift

  local provider_name="${base_name}_${STATE_PROVIDER}"
  debug "Running state function: ${provider_name}"

  if function_exists "$provider_name"; then
    "$provider_name" "$@"
  fi
  return $?
}

function run_provisioner_function () {
  local base_name="$1"
  shift

  local provider_name="${base_name}_${PROVISIONER_PROVIDER}"
  debug "Running provisioner function: ${provider_name}"

  if function_exists "$provider_name"; then
    "$provider_name" "$@"
  fi
  return $?
}


function ensure_remote_state () {
  if [ "${STATE_PROVIDER}" ]; then
    run_state_function ensure_remote_state
  fi
}

function destroy_remote_state () {
  if [ "${STATE_PROVIDER}" ]; then
    run_state_function destroy_remote_state
  fi
}

function get_remote_state () {
  if [ "${STATE_PROVIDER}" ]; then
    run_state_function get_remote_state
  else
    local options=()
    echo "${options[@]}"
  fi
}


function run_provisioner () {
  provisioner_environment
  install_argocd

  ensure_remote_state

  run_provisioner_function run_provisioner "$@"
  run_hook run_provisioner "$@"
}

function run_provisioner_destroy () {
  provisioner_environment
  install_argocd

  ensure_remote_state

  run_provisioner_function run_provisioner_destroy "$@"
  run_hook run_provisioner_destroy "$@"
}


function clean_provisioner () {
  provisioner_environment
  run_provisioner_function clean_provisioner
  destroy_remote_state
  run_hook clean_provisioner
}
