#
#=========================================================================================
# <Exec> Command
#

function exec_description () {
  render "Execute and watch a temporary command within the Kubernetes cluster"
}

function exec_command_environment () {
  namespace_option
  wait_option "for container creation" 3
  service_image_arg
  required_command_args
}

function exec_command () {
  minikube_environment

  if ! minikube_status; then
    emergency "Minikube is not running"
  fi

  POD_NAME="$(date +%Y%m%d%H%M%S)"
  BASE_ARGS=(
    "-n" "$SERVICE_NAMESPACE"
    "$POD_NAME"
  )
  COMMAND_ARGS=(
    "${BASE_ARGS[@]}"
    "--restart" "Never"
    "--image" "$SERVICE_IMAGE"
    "--command" "--" ${SERVICE_COMMAND[@]}
  )
  LOG_ARGS=(
    "${BASE_ARGS[@]}"
    "--pod-running-timeout" "30s"
    "--ignore-errors"
    "--tail" 100
    "--follow"
    "--timestamps"
  )
  DELETE_ARGS=(
    "${BASE_ARGS[@]}"
    "--force"
  )

  debug "> BASE_ARGS: ${BASE_ARGS[@]}"
  debug "> COMMAND_ARGS: ${COMMAND_ARGS[@]}"
  debug "> LOG_ARGS: ${LOG_ARGS[@]}"
  debug "> DELETE_ARGS: ${DELETE_ARGS[@]}"

  "${__binary_dir}/kubectl" run "${COMMAND_ARGS[@]}"
  sleep $WAIT
  "${__binary_dir}/kubectl" logs "${LOG_ARGS[@]}"
  "${__binary_dir}/kubectl" delete pod "${DELETE_ARGS[@]}" 2>/dev/null
  add_space
}
