#
#=========================================================================================
# MiniKube Utilities
#

export MINIKUBE_HOME="${__project_dir}/.minikube"
export KUBECONFIG="${__env_dir}/.kubeconfig"

export DEFAULT_MINIKUBE_DRIVER="docker"
export DEFAULT_MINIKUBE_NODES=1
export DEFAULT_MINIKUBE_CPUS=2
export DEFAULT_MINIKUBE_MEMORY=8192
export DEFAULT_KUBERNETES_VERSION="1.31.0"
export DEFAULT_MINIKUBE_CONTAINER_RUNTIME="docker"

function minikube_environment () {
  debug "Setting Minikube environment ..."
  export MINIKUBE_DRIVER="${MINIKUBE_DRIVER:-$DEFAULT_MINIKUBE_DRIVER}"
  export MINIKUBE_NODES="${MINIKUBE_NODES:-$DEFAULT_MINIKUBE_NODES}"
  export MINIKUBE_CPUS="${MINIKUBE_CPUS:-$DEFAULT_MINIKUBE_CPUS}"
  export MINIKUBE_MEMORY="${MINIKUBE_MEMORY:-$DEFAULT_MINIKUBE_MEMORY}"
  export MINIKUBE_KUBERNETES_VERSION="${MINIKUBE_KUBERNETES_VERSION:-$DEFAULT_KUBERNETES_VERSION}"
  export MINIKUBE_CONTAINER_RUNTIME="${MINIKUBE_CONTAINER_RUNTIME:-$DEFAULT_MINIKUBE_CONTAINER_RUNTIME}"

  debug "KUBECONFIG: ${KUBECONFIG}"
  debug "MINIKUBE_HOME: ${MINIKUBE_HOME}"
  debug "MINIKUBE_DRIVER: ${MINIKUBE_DRIVER}"
  debug "MINIKUBE_NODES: ${MINIKUBE_NODES}"
  debug "MINIKUBE_CPUS: ${MINIKUBE_CPUS}"
  debug "MINIKUBE_MEMORY: ${MINIKUBE_MEMORY}"
  debug "MINIKUBE_KUBERNETES_VERSION: ${MINIKUBE_KUBERNETES_VERSION}"
  debug "MINIKUBE_CONTAINER_RUNTIME: ${MINIKUBE_CONTAINER_RUNTIME}"

  debug "DOCKER_TLS_VERIFY: ${DOCKER_TLS_VERIFY:-}"
  debug "DOCKER_HOST: ${DOCKER_HOST:-}"
  debug "DOCKER_CERT_PATH: ${DOCKER_CERT_PATH:-}"
  debug "MINIKUBE_ACTIVE_DOCKERD: ${MINIKUBE_ACTIVE_DOCKERD:-}"
}


# Initialize Docker registry
if [ "$REACTOR_LOCAL" != "1" ]; then
  if minikube status 1>/dev/null 2>&1; then
    eval $(minikube docker-env)
  fi
fi


function minikube_status () {
  minikube_environment
  minikube status 1>/dev/null 2>&1
  return $?
}

function minikube_host_status () {
  # Runs on host machine
  minikube_environment
  "${__binary_dir}/minikube" status 1>/dev/null 2>&1
  return $?
}


function start_minikube () {
  if ! minikube_status; then
    info "Starting Minikube ..."
    minikube start \
      --driver=${MINIKUBE_DRIVER} \
      --nodes=${MINIKUBE_NODES} \
      --cpus=${MINIKUBE_CPUS} \
      --memory=${MINIKUBE_MEMORY} \
      --kubernetes-version=${MINIKUBE_KUBERNETES_VERSION} \
      --container-runtime=${MINIKUBE_CONTAINER_RUNTIME} \
      --addons="default-storageclass,storage-provisioner,metrics-server,dashboard" \
      --mount \
      --mount-string="${__project_dir}:${__project_dir}" \
      --embed-certs \
      --dns-domain="${PRIMARY_DOMAIN}"
  fi
  minikube update-context

  if [ "$REACTOR_LOCAL" != "1" ]; then
    eval $(minikube docker-env)

    debug "DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY}"
    debug "DOCKER_HOST=${DOCKER_HOST}"
    debug "DOCKER_CERT_PATH=${DOCKER_CERT_PATH}"
    debug "MINIKUBE_ACTIVE_DOCKERD=${MINIKUBE_ACTIVE_DOCKERD}"
  fi
}

function stop_minikube () {
  info "Stopping Minikube environment ..."
  if minikube_status; then
    minikube stop
    delete_minikube_kubeconfig
  fi
}

function stop_host_minikube () {
  # Runs on host machine
  terminate_host_minikube_tunnel
  terminate_host_minikube_dashboard
}

function destroy_minikube () {
  info "Destroying Minikube environment ..."

  minikube delete --purge
  delete_minikube_kubeconfig
  delete_minikube_storage

  # clean_helm
  # clean_argocd
}

function destroy_host_minikube () {
  # Runs on host machine
  terminate_host_minikube_tunnel
  terminate_host_minikube_dashboard
}


function launch_host_minikube_tunnel () {
  # Runs on host machine
  if minikube_host_status; then
    PID_FILE="${__log_dir}/tunnel.kpid"

    terminate_host_minikube_tunnel

    info "Launching Minikube tunnel (requires sudo) ..."
    check_admin
    "${__binary_dir}/minikube" tunnel 1>>"$(logfile)" 2>&1 &
    echo "$!" >"$PID_FILE"
  fi
}

function terminate_host_minikube_tunnel () {
  # Runs on host machine
  PID_FILE="${__log_dir}/tunnel.kpid"

  info "Terminating existing Minikube tunnel ..."

  if [ -f "$PID_FILE" ]; then
    if kill -s 0 "$(cat "$PID_FILE")" >/dev/null 2>&1; then
      kill "$(cat "$PID_FILE")"
    fi
    rm -f "$PID_FILE"
  fi
}

function launch_host_minikube_dashboard () {
  # Runs on host machine
  if minikube_host_status; then
    PID_FILE="${__log_dir}/dashboard.kpid"

    terminate_host_minikube_dashboard

    info "Launching Kubernetes Dashboard ..."
    "${__binary_dir}/minikube" dashboard 1>>"$(logfile)" 2>&1 &
    echo "$!" >"$PID_FILE"
  fi
}

function terminate_host_minikube_dashboard () {
  # Runs on host machine
  PID_FILE="${__log_dir}/dashboard.kpid"

  info "Terminating Minikube dashboard ..."

  if [ -f "$PID_FILE" ]; then
    if kill -s 0 "$(cat "$PID_FILE")" >/dev/null 2>&1; then
      kill "$(cat "$PID_FILE")"
    fi
    rm -f "$PID_FILE"
  fi
}


function delete_minikube_kubeconfig () {
  if [ -f "$KUBECONFIG" ]; then
    info "Deleting Minikube kubeconfig file ..."
    rm -f "$KUBECONFIG"
  fi
}

function delete_minikube_storage () {
  if [ -d "$MINIKUBE_HOME" ]; then
    info "Deleting Minikube project storage ..."
    rm -Rf "$MINIKUBE_HOME"
  fi
}
