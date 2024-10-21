#
#=========================================================================================
# <Logs> Command
#

function logs_description () {
  render "Return logging information for Kubernetes pods"
  export PASSTHROUGH="1"
}

function logs_command () {
  minikube_environment

  if ! minikube_status; then
    emergency "Minikube is not running"
  fi
  "${__binary_dir}/kubectl" logs --timestamps "$@"
  add_space
}
