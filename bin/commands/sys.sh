#
#=========================================================================================
# <Sys> Command
#

function sys_description () {
  render "Execute a kubectl operation within the reactor environment context"
  export PASSTHROUGH="1"
}

function sys_command () {
  kubernetes_environment

  if ! kubernetes_status; then
    emergency "Kubernetes is not running"
  fi
  "${__binary_dir}/kubectl" "$@"
  add_space
}
