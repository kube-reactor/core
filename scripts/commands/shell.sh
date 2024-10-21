#
#=========================================================================================
# <Shell> Command
#

function shell_description () {
  render "Open a terminal session to a running Minikube pod"
}

function shell_command_environment () {
  namespace_option
  command_option
  pod_arg
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
