#
#=========================================================================================
# <Launch> Command
#

function launch_description () {
  render "Launch a service within the Minikube cluster"
}

function launch_command_environment () {
  namespace_option
  pod_arg
  service_image_arg
}

function launch_command () {
  minikube_environment

  if ! minikube_status; then
    emergency "Minikube is not running"
  fi

  SERVICE_OPTIONS=(
    "-n" "$SERVICE_NAMESPACE"
    "--image" "$SERVICE_IMAGE"
  )
  "${__binary_dir}/kubectl" run \
    "${SERVICE_OPTIONS[@]}" \
    "$SERVICE_POD_NAME"
  add_space
}
