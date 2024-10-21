#
#=========================================================================================
# <Exec> Command
#

function exec_description () {
  render "Launch a service within the Kubernetes cluster"
}

function exec_command_environment () {
  namespace_option
  service_image_arg
  required_command_args
}

function exec_command () {
  minikube_environment

  if ! minikube_status; then
    emergency "Minikube is not running"
  fi

  render "$SERVICE_NAMESPACE"
  render "$SERVICE_IMAGE"
  render "${SERVICE_COMMAND[@]}"


  # SERVICE_OPTIONS=(
  #   "-n" "$SERVICE_NAMESPACE"
  #   "--image" "$SERVICE_IMAGE"
  # )
  # COMMAND=()
  # if [ "$SERVICE_COMMAND" ]; then
  #   SERVICE_OPTIONS=("${SERVICE_OPTIONS[@]}" "-it" "--rm")
  #   COMMAND=("${COMMAND[@]}" "--" "$SERVICE_COMMAND")
  # fi
  # "${__binary_dir}/kubectl" run \
  #   "${SERVICE_OPTIONS[@]}" \
  #   "$SERVICE_POD_NAME" \
  #   "${COMMAND[@]}"
  # add_space
}
