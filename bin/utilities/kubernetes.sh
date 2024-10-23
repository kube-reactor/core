#
#=========================================================================================
# Kubernetes Utilities
#
export DEFAULT_KUBERNETES_PROVIDER="minikube"
export DEFAULT_KUBERNETES_VERSION="1.31.0"
export DEFAULT_KUBECTL_VERSION="1.31.0"


function kubernetes_environment () {
  debug "Setting Kubernetes environment ..."
  export KUBERNETES_PROVIDER="${KUBERNETES_PROVIDER:-$DEFAULT_KUBERNETES_PROVIDER}"
  export KUBERNETES_VERSION="${KUBERNETES_VERSION:-$DEFAULT_KUBERNETES_VERSION}"
  export KUBECTL_VERSION="${KUBECTL_VERSION:-$DEFAULT_KUBECTL_VERSION}"
  export KUBECONFIG=""

  if check_project; then
    export KUBECONFIG="${__env_dir}/.kubeconfig"
  fi
  debug "KUBECONFIG: ${KUBECONFIG}"
  debug "KUBERNETES_PROVIDER: ${KUBERNETES_PROVIDER}"
  debug "KUBERNETES_VERSION: ${KUBERNETES_VERSION}"
  debug "KUBECTL_VERSION: ${KUBECTL_VERSION}"
}


function run_kube_function () {
  kubernetes_environment

  local base_name="$1"
  shift

  local provider_name="${base_name}_${KUBERNETES_PROVIDER}"

  debug "Running Kubernetes function: ${provider_name}"
  kubernetes_environment

  if function_exists "$provider_name"; then
    debug "Kubernetes function found"
    "$provider_name" "$@"
  fi
  return $?
}


function install_kubernetes () {
  kubernetes_environment
  run_kube_function install_kubernetes

  download_binary kubectl \
    "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${__architecture}/kubectl" \
    "${__binary_dir}"

  install_helm
  install_argocd
}


function kubernetes_status () {
  run_kube_function kubernetes_status
  return $?
}


function start_kubernetes () {
  if ! kubernetes_status; then
    info "Starting Kubernetes ..."
    run_kube_function start_kubernetes
  fi
  add_docker_environment
}

function stop_kubernetes () {
  info "Stopping Kubernetes environment ..."
  if kubernetes_status; then
    run_kube_function stop_kubernetes
    delete_kubernetes_kubeconfig
  fi
}

function stop_host_kubernetes () {
  # Runs on host machine
  run_kube_function stop_host_kubernetes

  terminate_host_kubernetes_tunnel
  terminate_host_kubernetes_dashboard
}

function destroy_kubernetes () {
  info "Destroying Kubernetes environment ..."
  run_kube_function destroy_kubernetes

  delete_kubernetes_kubeconfig
  delete_kubernetes_storage
  delete_docker_environment

  rm -f "$(logdir)/docker.sh"
}

function destroy_host_kubernetes () {
  # Runs on host machine
  run_kube_function destroy_host_kubernetes

  terminate_host_kubernetes_tunnel
  terminate_host_kubernetes_dashboard
}

function delete_kubernetes_kubeconfig () {
  if [ -f "$KUBECONFIG" ]; then
    info "Deleting Kubernetes kubeconfig file ..."
    rm -f "$KUBECONFIG"
  fi
}

function delete_kubernetes_storage () {
  run_kube_function delete_kubernetes_storage
}


function launch_host_kubernetes_tunnel () {
  # Runs on host machine
  if kubernetes_status; then
    terminate_host_kubernetes_tunnel
    run_kube_function launch_host_kubernetes_tunnel
  fi
}

function terminate_host_kubernetes_tunnel () {
  # Runs on host machine
  info "Terminating existing Kubernetes tunnel ..."
  run_kube_function terminate_host_kubernetes_tunnel
}

function launch_host_kubernetes_dashboard () {
  # Runs on host machine
  if kubernetes_status; then
    terminate_host_kubernetes_dashboard
    run_kube_function launch_host_kubernetes_dashboard
  fi
}

function terminate_host_kubernetes_dashboard () {
  # Runs on host machine
  info "Terminating existing Kubernetes dashboard ..."
  run_kube_function terminate_host_kubernetes_dashboard
}


function get_pods () {
  namespace="$1"
  pod_list="$(kubectl get pods -n "$namespace" --no-headers -o custom-columns=':metadata.name')"

  for pod in ${pod_list[@]}; do
    echo "$pod"
  done
}
