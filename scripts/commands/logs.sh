#
#=========================================================================================
# <Logs> Command
#

function logs_description () {
  render "Return logging information for Kubernetes pods"
  export PASSTHROUGH="1"
}

function logs_command () {
  kubernetes_environment

  if ! kubernetes_status; then
    emergency "Kubernetes is not running"
  fi
  "${__binary_dir}/kubectl" logs --timestamps "$@"
  add_space
}
