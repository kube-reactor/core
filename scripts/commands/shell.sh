#
#=========================================================================================
# <Shell> Command
#

function shell_description () {
  echo "Open a terminal session to a running Minikube service"
}

function shell_command_environment () {
  parse_option --namespace \
    SERVICE_NAMESPACE \
    "Kubernetes namespace" \
    default

  parse_arg service_pod_name \
    SERVICE_POD_NAME \
    "Kubernetes service pod name"

  parse_arg service_command \
    SERVICE_COMMAND \
    "Kubernetes service command"
    bash
}

function shell_command () {
  minikube_environment

  if ! minikube_status; then
    emergency "Minikube is not running"
  fi
  "${__binary_dir}/kubectl" exec \
    -n "$SERVICE_NAMESPACE" \
    -ti "$SERVICE_POD_NAME" \
    -- "$SERVICE_COMMAND"
}
