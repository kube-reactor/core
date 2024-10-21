#
#=========================================================================================
# <Pods> Command
#

function pods_description () {
  render "List all pods in a Kubernetes namespace"
}

function pods_command_environment () {
  namespace_option
}

function pods_command () {
  kubernetes_environment

  if ! kubernetes_status; then
    emergency "Kubernetes is not running"
  fi
  "${__binary_dir}/kubectl" get pods -n "$SERVICE_NAMESPACE"
  add_space
}
