#
#=========================================================================================
# MiniKube Utilities
#

export DEFAULT_MINIKUBE_DRIVER="docker"
export DEFAULT_MINIKUBE_NODES=1
export DEFAULT_MINIKUBE_CPUS=2
export DEFAULT_MINIKUBE_MEMORY=8192
export DEFAULT_KUBERNETES_VERSION="1.30.0"
export DEFAULT_MINIKUBE_CONTAINER_RUNTIME="docker"

function minikube_environment () {
  debug "Setting Minikube environment ..."
  export MINIKUBE_DRIVER="${MINIKUBE_DRIVER:-$DEFAULT_MINIKUBE_DRIVER}"
  export MINIKUBE_NODES="${MINIKUBE_NODES:-$DEFAULT_MINIKUBE_NODES}"
  export MINIKUBE_CPUS="${MINIKUBE_CPUS:-$DEFAULT_MINIKUBE_CPUS}"
  export MINIKUBE_MEMORY="${MINIKUBE_MEMORY:-$DEFAULT_MINIKUBE_MEMORY}"
  export MINIKUBE_KUBERNETES_VERSION="${MINIKUBE_KUBERNETES_VERSION:-$DEFAULT_KUBERNETES_VERSION}"
  export MINIKUBE_CONTAINER_RUNTIME="${MINIKUBE_CONTAINER_RUNTIME:-$DEFAULT_MINIKUBE_CONTAINER_RUNTIME}"

  debug "export MINIKUBE_DRIVER: ${MINIKUBE_DRIVER}"
  debug "export MINIKUBE_NODES: ${MINIKUBE_NODES}"
  debug "export MINIKUBE_CPUS: ${MINIKUBE_CPUS}"
  debug "export MINIKUBE_MEMORY: ${MINIKUBE_MEMORY}"
  debug "export MINIKUBE_KUBERNETES_VERSION: ${MINIKUBE_KUBERNETES_VERSION}"
  debug "export MINIKUBE_CONTAINER_RUNTIME: ${MINIKUBE_CONTAINER_RUNTIME}"
}

function minikube_status () {
  minikube_environment

  if [ -f "${__binary_dir}/minikube" ]; then
    "${__binary_dir}/minikube" status 1>/dev/null 2>&1
    return $?
  fi
  return 1
}

# function push_minikube_image () {
#   if minikube_status; then
#     info "Pushing local image to Minikube registry ..."
#     "${__binary_dir}/minikube" image load "$IMAGE"
#   fi
# }

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
      --mount-string="${__project_dir}:/project"
  fi
}

function launch_minikube_tunnel () {
  if minikube_status; then
    PID_FILE="${__log_dir}/tunnel.kpid"
    LOG_FILE="${__log_dir}/tunnel.log"

    terminate_minikube_tunnel

    info "Launching Minikube tunnel ..."
    "${__binary_dir}/minikube" tunnel >"$LOG_FILE" 2>&1 &
    echo "$!" >"$PID_FILE"
  fi
}

function terminate_minikube_tunnel () {
  if minikube_status; then
    PID_FILE="${__log_dir}/tunnel.kpid"
    LOG_FILE="${__log_dir}/tunnel.log"

    info "Terminating existing Minikube tunnel ..."

    if [ -f "$PID_FILE" ]; then
      if kill -s 0 "$(cat "$PID_FILE")" >/dev/null 2>&1; then
        kill "$(cat "$PID_FILE")"
      fi
      rm -f "$PID_FILE"
    fi
    if [ -f "$LOG_FILE" ]; then
      rm -f "$LOG_FILE"
    fi
  fi
}

function launch_minikube_dashboard () {
  if minikube_status; then
    PID_FILE="${__log_dir}/dashboard.kpid"
    LOG_FILE="${__log_dir}/dashboard.log"

    terminate_minikube_dashboard

    info "Launching Kubernetes Dashboard ..."
    "${__binary_dir}/minikube" dashboard >"$LOG_FILE" 2>&1 &
    echo "$!" >"$PID_FILE"
  fi
}

function terminate_minikube_dashboard () {
  if minikube_status; then
    PID_FILE="${__log_dir}/dashboard.kpid"
    LOG_FILE="${__log_dir}/dashboard.log"

    info "Terminating Minikube dashboard ..."

    if [ -f "$PID_FILE" ]; then
      if kill -s 0 "$(cat "$PID_FILE")" >/dev/null 2>&1; then
        kill "$(cat "$PID_FILE")"
      fi
      rm -f "$PID_FILE"
    fi
    if [ -f "$LOG_FILE" ]; then
      rm -f "$LOG_FILE"
    fi
  fi
}

# function start_zimagi_session () {
#   ZIMAGI_SERVICE="${1:-}"

#   if ! minikube_status; then
#     emergency "Minikube is not running"
#   fi

#   PODS=($(kubectl get pods -n zimagi -l "app.kubernetes.io/name=zimagi" -o=jsonpath='{.items[*].metadata.name}' ))

#   if ! [ ${#PODS[@]} -eq 0 ]; then
#     if [ -z "$ZIMAGI_SERVICE" ]; then
#       for index in $(seq 1 ${#PODS[@]}); do
#         echo "[ ${index} ] - ${PODS[$index - 1]}"
#       done
#       read -p "Enter number: " POD_INPUT
#       ZIMAGI_SERVICE="${PODS[$POD_INPUT-1]}"
#     fi
#     kubectl exec -n zimagi -ti "$ZIMAGI_SERVICE" -- bash
#   else
#     alert "Zimagi services are not running"
#   fi
# }

function stop_minikube () {
  info "Stopping Minikube environment ..."
  if minikube_status; then
    terminate_minikube_tunnel
    terminate_minikube_dashboard

    "${__binary_dir}/minikube" stop
  fi
  delete_minikube_kubeconfig
}

function destroy_minikube () {
  info "Destroying Minikube environment ..."
  if [ -f "${__binary_dir}/minikube" ]; then
    terminate_minikube_tunnel
    terminate_minikube_dashboard

    "${__binary_dir}/minikube" delete --purge
  fi
  delete_minikube_kubeconfig
  delete_minikube_storage
  # clean_helm
  # clean_argocd
}

function delete_minikube_kubeconfig () {
  if [ -f "${__binary_dir}/minikube" ]; then
    if [ -f "${__log_dir}/.kubeconfig" ]; then
      info "Deleting Minikube kubeconfig file ..."
      rm -f "${__log_dir}/.kubeconfig"
    fi
  fi
}

function delete_minikube_storage () {
  if [ -f "${__binary_dir}/minikube" ]; then
    if [ -d "${__log_dir}/minikube" ]; then
      info "Deleting Minikube project storage ..."
      sudo rm -Rf "${__log_dir}/minikube"
    fi
  fi
}
