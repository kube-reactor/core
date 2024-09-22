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
export DEFAULT_KUBECTL_VERSION="1.31.0"
export DEFAULT_MINIKUBE_CONTAINER_RUNTIME="docker"

function minikube_environment () {
  debug "Setting Minikube environment ..."
  export MINIKUBE_DRIVER="${MINIKUBE_DRIVER:-$DEFAULT_MINIKUBE_DRIVER}"
  export MINIKUBE_NODES="${MINIKUBE_NODES:-$DEFAULT_MINIKUBE_NODES}"
  export MINIKUBE_CPUS="${MINIKUBE_CPUS:-$DEFAULT_MINIKUBE_CPUS}"
  export MINIKUBE_MEMORY="${MINIKUBE_MEMORY:-$DEFAULT_MINIKUBE_MEMORY}"
  export MINIKUBE_KUBERNETES_VERSION="${MINIKUBE_KUBERNETES_VERSION:-$DEFAULT_KUBERNETES_VERSION}"
  export MINIKUBE_CONTAINER_RUNTIME="${MINIKUBE_CONTAINER_RUNTIME:-$DEFAULT_MINIKUBE_CONTAINER_RUNTIME}"
  export KUBECTL_VERSION="${KUBECTL_VERSION:-$DEFAULT_KUBECTL_VERSION}"

  debug "KUBECONFIG: ${KUBECONFIG}"
  debug "MINIKUBE_HOME: ${MINIKUBE_HOME}"
  debug "MINIKUBE_DRIVER: ${MINIKUBE_DRIVER}"
  debug "MINIKUBE_NODES: ${MINIKUBE_NODES}"
  debug "MINIKUBE_CPUS: ${MINIKUBE_CPUS}"
  debug "MINIKUBE_MEMORY: ${MINIKUBE_MEMORY}"
  debug "MINIKUBE_KUBERNETES_VERSION: ${MINIKUBE_KUBERNETES_VERSION}"
  debug "MINIKUBE_CONTAINER_RUNTIME: ${MINIKUBE_CONTAINER_RUNTIME}"
  debug "KUBECTL_VERSION: ${KUBECTL_VERSION}"
}

function add_minikube_docker_environment () {
  docker_vars_file="${__log_dir}/docker.sh"

  if [ ! -f "$docker_vars_file" ]; then
    touch "$docker_vars_file"

    if [ ! -z "${DOCKER_TLS_VERIFY:-}" ]; then
      echo "DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY}" >>"$docker_vars_file"
    fi
    if [ ! -z "${DOCKER_HOST:-}" ]; then
      echo "DOCKER_HOST=${DOCKER_HOST}" >>"$docker_vars_file"
    fi
    if [ ! -z "${DOCKER_CERT_PATH:-}" ]; then
      echo "DOCKER_CERT_PATH=${DOCKER_CERT_PATH}" >>"$docker_vars_file"
    fi
    if [ ! -z "${MINIKUBE_ACTIVE_DOCKERD:-}" ]; then
      echo "MINIKUBE_ACTIVE_DOCKERD=${MINIKUBE_ACTIVE_DOCKERD}" >>"$docker_vars_file"
    fi
  fi
  eval $("${__binary_dir}/minikube" docker-env)

  debug "DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY}"
  debug "DOCKER_HOST=${DOCKER_HOST}"
  debug "DOCKER_CERT_PATH=${DOCKER_CERT_PATH}"
  debug "MINIKUBE_ACTIVE_DOCKERD=${MINIKUBE_ACTIVE_DOCKERD}"
}

function delete_minikube_docker_environment () {
  docker_vars_file="${__log_dir}/docker.sh"

  unset DOCKER_TLS_VERIFY
  unset DOCKER_HOST
  unset DOCKER_CERT_PATH
  unset MINIKUBE_ACTIVE_DOCKERD

  if [ -f "$docker_vars_file" ]; then
    source "$docker_vars_file"
  fi
}


# Initialize Docker registry
if [[ $REACTOR_LOCAL -eq 0 ]] || [[ $SOURCED -eq 1 ]]; then
  if "${__binary_dir}/minikube" status 1>/dev/null 2>&1; then
    add_minikube_docker_environment
  fi
fi


function minikube_status () {
  minikube_environment
  "${__binary_dir}/minikube" status 1>/dev/null 2>&1
  return $?
}

function start_minikube () {
  if ! minikube_status; then
    info "Starting Minikube ..."
    "${__binary_dir}/minikube" start \
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
      --dns-domain="${PRIMARY_DOMAIN}" 1>>"$(logfile)" 2>&1
  fi
  "${__binary_dir}/minikube" update-context 1>>"$(logfile)" 2>&1
  add_minikube_docker_environment
}

function stop_minikube () {
  info "Stopping Minikube environment ..."
  if minikube_status; then
    "${__binary_dir}/minikube" stop 1>>"$(logfile)" 2>&1
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
  "${__binary_dir}/minikube" delete --purge 1>>"$(logfile)" 2>&1

  delete_minikube_kubeconfig
  delete_minikube_storage
  delete_minikube_docker_environment

  rm -f "${__log_dir}/docker.sh"
}

function destroy_host_minikube () {
  # Runs on host machine
  terminate_host_minikube_tunnel
  terminate_host_minikube_dashboard
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


function launch_host_minikube_tunnel () {
  # Runs on host machine
  if minikube_status; then
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
  if minikube_status; then
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
