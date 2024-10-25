#
#=========================================================================================
# <Shell> Command
#

function shell_description () {
  render "Open a terminal session to a running Kubernetes pod"
}

function shell_command_environment () {
  namespace_option
  command_option
  pod_arg
}

function shell_command () {
  kubernetes_environment

  if ! kubernetes_status; then
    emergency "Kubernetes is not running"
  fi
  "${__bin_dir}/kubectl" exec \
    -n "$SERVICE_NAMESPACE" \
    -ti "$SERVICE_POD_NAME" \
    -- "$SERVICE_COMMAND"
}
