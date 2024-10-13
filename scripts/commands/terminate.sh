#
#=========================================================================================
# <Terminate> Command
#

function terminate_description () {
  echo "Terminate a service within the Minikube cluster"
}

function terminate_command_environment () {
  parse_option --namespace \
    SERVICE_NAMESPACE \
    "Kubernetes namespace" \
    default

  parse_arg service_pod_name \
    SERVICE_POD_NAME \
    "Kubernetes service pod name"
}

function terminate_command () {
  minikube_environment

  if ! minikube_status; then
    emergency "Minikube is not running"
  fi
  "${__binary_dir}/kubectl" delete pod \
    -n "$SERVICE_NAMESPACE" \
    "$SERVICE_POD_NAME"
  echo ""
}
