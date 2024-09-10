#
#=========================================================================================
# <Launch> Command
#

function launch_description () {
  echo "Launch a service within the Minikube cluster"
}
function launch_usage () {
    cat <<EOF >&2

$(launch_description)

Usage:

  kubectl reactor launch [flags] [options] <service_pod_name:str> <service_image:str>

Flags:
${__reactor_core_flags}

    --namespace           Kubernetes namespace
EOF
  exit 1
}
function launch_command () {
  SERVICE_POD_NAME=""
  SERVICE_IMAGE=""
  SERVICE_NAMESPACE="default"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --namespace=*)
      SERVICE_NAMESPACE="${1#*=}"
      ;;
      --namespace)
      SERVICE_NAMESPACE="$2"
      shift
      ;;
      -h|--help)
      launch_usage
      ;;
      *)
      if [[ "$1" == "-"* ]] || [ ! -z "$SERVICE_POD_NAME" -a ! -z "$SERVICE_IMAGE" ]; then
        error "Unknown argument: ${1}"
        launch_usage
      fi
      if [ -z "$SERVICE_POD_NAME" ]; then
        SERVICE_POD_NAME="${1}"
      elif [ -z "$SERVICE_IMAGE" ]; then
        SERVICE_IMAGE="${1}"
      fi
      ;;
    esac
    shift
  done

  MISSING_ARGS=0

  if [ -z "$SERVICE_POD_NAME" ]; then
    alert "Service pod name argument required"
    MISSING_ARGS=1
  fi
  if [ -z "$SERVICE_IMAGE" ]; then
    alert "Service image argument required"
    MISSING_ARGS=1
  fi
  if [ $MISSING_ARGS -eq 1 ]; then
    launch_usage
    exit 1
  fi

  minikube_environment

  debug "Command: launch"
  debug "> SERVICE_POD_NAME: ${SERVICE_POD_NAME}"
  debug "> SERVICE_IMAGE: ${SERVICE_IMAGE}"
  debug "> SERVICE_NAMESPACE: ${SERVICE_NAMESPACE}"

  if ! minikube_status; then
    emergency "Minikube is not running"
  fi

  kubectl run -n "$SERVICE_NAMESPACE" "$SERVICE_POD_NAME" --image="$SERVICE_IMAGE"
  echo ""
}
