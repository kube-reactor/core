#
#=========================================================================================
# <Terminate> Command
#

function terminate_description () {
  render "Terminate a service within the Minikube cluster"
}

function terminate_command_environment () {
  namespace_option
  pod_arg
}

function terminate_command () {
  minikube_environment

  if ! minikube_status; then
    emergency "Minikube is not running"
  fi
  "${__binary_dir}/kubectl" delete pod \
    -n "$SERVICE_NAMESPACE" \
    "$SERVICE_POD_NAME"
  add_space
}
