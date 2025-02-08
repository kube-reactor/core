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

function kubernetes_application_environment () {
  export TF_VAR_project_path="${__project_dir}"
  export TF_VAR_project_wait="$PROJECT_UPDATE_WAIT"
  export TF_VAR_argocd_admin_password="$("${__bin_dir}/argocd" account bcrypt --password "${ARGOCD_ADMIN_PASSWORD:-admin}")"

  if [ ! -z "${ARGOCD_PROJECT_SEQUENCE}" ]; then
    export TF_VAR_argocd_project_sequence="${ARGOCD_PROJECT_SEQUENCE}"
  fi
  debug "TF_VAR_project_path: ${TF_VAR_project_path}"
  debug "TF_VAR_project_wait: ${TF_VAR_project_wait}"
  debug "TF_VAR_argocd_admin_password: ${TF_VAR_argocd_admin_password}"
  debug "TF_VAR_argocd_project_sequence: ${TF_VAR_argocd_project_sequence:-}"
}


function run_kube_function () {
  kubernetes_environment

  local base_name="$1"
  shift

  local provider_name="${base_name}_${KUBERNETES_PROVIDER}"
  debug "Running Kubernetes function: ${provider_name}"

  if function_exists "$provider_name"; then
    "$provider_name" "$@"
  fi
  return $?
}


function install_kubernetes () {
  download_binary kubectl \
    "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${__architecture}/kubectl" \
    "${__bin_dir}"

  install_helm
  install_argocd

  run_kube_function install_kubernetes
}


function kubernetes_status () {
  run_kube_function kubernetes_status
  return $?
}


function start_kubernetes () {
  provisioner_environment

  info "Starting Kubernetes ..."
  run_kube_function start_kubernetes
  add_container_environment
}


function provision_kubernetes_applications () {
  provisioner_environment
  kubernetes_environment
  kubernetes_application_environment

  if kubernetes_status; then
    run_kube_function provision_kubernetes_applications
  fi
}

function destroy_kubernetes_applications () {
  provisioner_environment
  kubernetes_environment
  kubernetes_application_environment

  if kubernetes_status; then
    run_kube_function destroy_kubernetes_applications
  fi
}


function stop_kubernetes () {
  provisioner_environment

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
  provisioner_environment
  kubernetes_environment

  info "Destroying Kubernetes environment ..."
  export TF_VAR_project_path="${__project_dir}"
  export TF_VAR_project_wait="$PROJECT_UPDATE_WAIT"
  export TF_VAR_argocd_admin_password="$("${__bin_dir}/argocd" account bcrypt --password "${ARGOCD_ADMIN_PASSWORD:-admin}")"

  if [ ! -z "${ARGOCD_PROJECT_SEQUENCE}" ]; then
    export TF_VAR_argocd_project_sequence="${ARGOCD_PROJECT_SEQUENCE}"
  fi

  run_kube_function destroy_kubernetes

  delete_kubernetes_kubeconfig
  delete_kubernetes_storage
  delete_container_environment
}

function destroy_host_kubernetes () {
  # Runs on host machine
  run_kube_function destroy_host_kubernetes

  terminate_host_kubernetes_tunnel
  terminate_host_kubernetes_dashboard
}

function delete_kubernetes_kubeconfig () {
  kubernetes_environment

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


function get_config_value () {
  local namespace="$1"
  local name="$2"
  local property="$3"
  echo -n "$(kubectl get cm "$name" -n "$namespace" -o jsonpath="{.data.${property//./\\.}}")"
}

function get_secret_value () {
  local namespace="$1"
  local name="$2"
  local property="$3"
  echo "$(kubectl get secret "$name" -n "$namespace" -o go-template="{{ index .data "\"$property\"" | base64decode }}")"
}

function get_pods () {
  namespace="$1"
  pod_list="$(kubectl get pods -n "$namespace" --no-headers -o custom-columns=':metadata.name')"

  for pod in ${pod_list[@]}; do
    echo "$pod"
  done
}
