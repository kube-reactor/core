#
#=========================================================================================
# <Sys> Command
#

function sys_description () {
  echo "Execute a kubectl operation within the reactor environment context"
  export PASSTHROUGH="1"
}

function sys_command () {
  minikube_environment

  if ! minikube_status; then
    emergency "Minikube is not running"
  fi
  "${__binary_dir}/kubectl" "$@"
  echo ""
}
