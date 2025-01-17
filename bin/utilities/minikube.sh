#
#=========================================================================================
# MiniKube Utilities
#
export DEFAULT_MINIKUBE_DRIVER="docker"
export DEFAULT_MINIKUBE_NODES=1
export DEFAULT_MINIKUBE_CPUS=2
export DEFAULT_MINIKUBE_MEMORY=8192
export DEFAULT_MINIKUBE_CONTAINER_RUNTIME="docker"


function minikube_environment () {
  if [ "${__project_dir:-}" ]; then
    debug "Setting Minikube environment ..."
    export MINIKUBE_HOME="${__project_dir}/.minikube"
    export MINIKUBE_DRIVER="${MINIKUBE_DRIVER:-$DEFAULT_MINIKUBE_DRIVER}"
    export MINIKUBE_NODES="${MINIKUBE_NODES:-$DEFAULT_MINIKUBE_NODES}"
    export MINIKUBE_CPUS="${MINIKUBE_CPUS:-$DEFAULT_MINIKUBE_CPUS}"
    export MINIKUBE_MEMORY="${MINIKUBE_MEMORY:-$DEFAULT_MINIKUBE_MEMORY}"
    export MINIKUBE_CONTAINER_RUNTIME="${MINIKUBE_CONTAINER_RUNTIME:-$DEFAULT_MINIKUBE_CONTAINER_RUNTIME}"

    debug "MINIKUBE_HOME: ${MINIKUBE_HOME}"
    debug "MINIKUBE_DRIVER: ${MINIKUBE_DRIVER}"
    debug "MINIKUBE_NODES: ${MINIKUBE_NODES}"
    debug "MINIKUBE_CPUS: ${MINIKUBE_CPUS}"
    debug "MINIKUBE_MEMORY: ${MINIKUBE_MEMORY}"
    debug "MINIKUBE_CONTAINER_RUNTIME: ${MINIKUBE_CONTAINER_RUNTIME}"
  fi
}

function add_docker_environment_minikube () {
  if [[ "${APP_NAME:-}" ]] && kubernetes_status_minikube; then
    eval $("${__bin_dir}/minikube" docker-env --profile="${APP_NAME}")

    debug "DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY}"
    debug "DOCKER_HOST=${DOCKER_HOST}"
    debug "DOCKER_CERT_PATH=${DOCKER_CERT_PATH}"
    debug "MINIKUBE_ACTIVE_DOCKERD=${MINIKUBE_ACTIVE_DOCKERD}"
  fi
}


function install_kubernetes_minikube () {
  minikube_environment

  download_binary minikube \
    "https://storage.googleapis.com/minikube/releases/latest/minikube-${__os}-${__architecture}" \
    "${__bin_dir}"
}


function kubernetes_status_minikube () {
  minikube_environment
  if [ "${APP_NAME:-}" ]; then
    "${__bin_dir}/minikube" status --profile="${APP_NAME}" 1>/dev/null 2>&1
  fi
  return $?
}

function start_kubernetes_minikube () {
  minikube_environment
  "${__bin_dir}/minikube" start \
    --profile="${APP_NAME}" \
    --driver="${MINIKUBE_DRIVER}" \
    --nodes="${MINIKUBE_NODES}" \
    --cpus="${MINIKUBE_CPUS}" \
    --memory="${MINIKUBE_MEMORY}" \
    --kubernetes-version="${KUBERNETES_VERSION}" \
    --container-runtime="${MINIKUBE_CONTAINER_RUNTIME}" \
    --addons="default-storageclass,storage-provisioner,metrics-server,dashboard" \
    --mount \
    --mount-string="${__project_dir}:${__project_dir}" \
    --embed-certs \
    --dns-domain="${PRIMARY_DOMAIN}" 1>>"$(logfile)" 2>&1

  "${__bin_dir}/minikube" --profile="${APP_NAME}" update-context 1>>"$(logfile)" 2>&1
}

function stop_kubernetes_minikube () {
  "${__bin_dir}/minikube" stop --profile="${APP_NAME}" 1>>"$(logfile)" 2>&1
}

function destroy_kubernetes_minikube () {
  "${__bin_dir}/minikube" delete --profile="${APP_NAME}" --purge 1>>"$(logfile)" 2>&1
}

function delete_kubernetes_storage_minikube () {
  minikube_environment
  if [ -d "$MINIKUBE_HOME" ]; then
    info "Deleting Minikube project storage ..."
    rm -Rf "$MINIKUBE_HOME"
  fi
}


function launch_host_kubernetes_tunnel_minikube () {
  # Runs on host machine
  PID_FILE="$(logdir)/tunnel.kpid"

  info "Launching Minikube tunnel (requires sudo) ..."
  check_admin
  "${__bin_dir}/minikube" tunnel --profile="${APP_NAME}" 1>>"$(logfile)" 2>&1 &
  echo "$!" >"$PID_FILE"
}

function terminate_host_kubernetes_tunnel_minikube () {
  # Runs on host machine
  PID_FILE="$(logdir)/tunnel.kpid"

  if [ -f "$PID_FILE" ]; then
    if kill -s 0 "$(cat "$PID_FILE")" >/dev/null 2>&1; then
      kill "$(cat "$PID_FILE")"
    fi
    rm -f "$PID_FILE"
  fi
}


function launch_host_kubernetes_dashboard_minikube () {
  # Runs on host machine
  PID_FILE="$(logdir)/dashboard.kpid"

  info "Launching Kubernetes Dashboard ..."
  "${__bin_dir}/minikube" dashboard --profile="${APP_NAME}" 1>>"$(logfile)" 2>&1 &
  echo "$!" >"$PID_FILE"
}

function terminate_host_kubernetes_dashboard_minikube () {
  # Runs on host machine
  PID_FILE="$(logdir)/dashboard.kpid"

  if [ -f "$PID_FILE" ]; then
    if kill -s 0 "$(cat "$PID_FILE")" >/dev/null 2>&1; then
      kill "$(cat "$PID_FILE")"
    fi
    rm -f "$PID_FILE"
  fi
}
