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

  run_provisioner_function provisioner_environment
}


function provisioner_create () {
  local provisioner_name="$1"
  local provisioner_dir="$2"
  local local_state="${3:-}"

  if [ ! -d "$provisioner_dir" ]; then
    emergency "In order to provision ${provisioner_name} you must specify a valid project directory.  Given: ${provisioner_dir}"
  fi

  info "Creating ${provisioner_name} ..."
  load_hook "${provisioner_name}_variables"

  run_provisioner "$provisioner_dir" "$provisioner_name" "$local_state"
  run_hook "create_${provisioner_name}"
}


function provisioner_destroy () {
  local provisioner_name="$1"
  local provisioner_dir="$2"
  local local_state="${3:-}"

  if [ ! -d "$provisioner_dir" ]; then
    emergency "In order to destroy ${provisioner_name} you must specify a valid project directory.  Given: ${provisioner_dir}"
  fi

  info "Destroying ${provisioner_name} ..."
  load_hook "${provisioner_name}_variables"
  run_provisioner_destroy "$provisioner_dir" "$provisioner_name" "$local_state"
  run_hook "destroy_${provisioner_name}"
}

function provisioner_delete () {
  local provisioner_name="$1"
  local provisioner_dir="$2"
  local local_state="${3:-}"

  if [ ! -d "$provisioner_dir" ]; then
    emergency "In order to delete ${provisioner_name} you must specify a valid project directory.  Given: ${provisioner_dir}"
  fi

  info "Deleting ${provisioner_name} ..."
  load_hook "${provisioner_name}_variables"
  run_provisioner_delete "$provisioner_dir" "$provisioner_name" "$local_state"
  run_hook "delete_${provisioner_name}"
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
  if [ "${STATE_PROVIDER:-}" ]; then
    run_state_function ensure_remote_state
  fi
}

function destroy_remote_state () {
  if [ "${STATE_PROVIDER:-}" ]; then
    run_state_function destroy_remote_state
  fi
}

function get_remote_state () {
  local project_type="$1"

  if [ "${STATE_PROVIDER:-}" ]; then
    run_state_function get_remote_state "$project_type"
  else
    local options=()
    echo "${options[@]}"
  fi
}


function run_provisioner () {
  provisioner_environment
  install_argocd

  run_provisioner_function run_provisioner "$@"
  run_hook run_provisioner "$@"
}

function run_provisioner_destroy () {
  provisioner_environment
  install_argocd

  run_provisioner_function run_provisioner_destroy "$@"
  run_hook run_provisioner_destroy "$@"
}

function run_provisioner_delete () {
  provisioner_environment
  install_argocd

  run_provisioner_function run_provisioner_delete "$@"
  run_hook run_provisioner_delete "$@"
}

function clean_provisioner () {
  provisioner_environment
  run_provisioner_function clean_provisioner
  run_hook clean_provisioner
}
