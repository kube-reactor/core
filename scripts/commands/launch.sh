#
#=========================================================================================
# <Launch> Command
#

function launch_description () {
  echo "Launch a service within the Minikube cluster"
}

function launch_command_environment () {
  parse_option --namespace \
    SERVICE_NAMESPACE \
    "Kubernetes namespace" \
    default

  parse_arg service_pod_name \
    SERVICE_POD_NAME \
    "Kubernetes service pod name"

  parse_arg service_image \
    SERVICE_IMAGE \
    "Kubernetes service container image"
}

function launch_command () {
  minikube_environment

  if ! minikube_status; then
    emergency "Minikube is not running"
  fi
  "${__binary_dir}/kubectl" run \
    -n "$SERVICE_NAMESPACE" \
    --image "$SERVICE_IMAGE" \
    "$SERVICE_POD_NAME"
  echo ""
}
