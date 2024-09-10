#
#=========================================================================================
# <Terminate> Command
#

function terminate_description () {
  echo "Terminate a service within the Minikube cluster"
}
function terminate_usage () {
    cat <<EOF >&2

$(terminate_description)

Usage:

  kubectl reactor terminate [flags] [options] <service_pod_name:str>

Flags:
${__reactor_core_flags}

    --namespace           Kubernetes namespace
EOF
  exit 1
}
function terminate_command () {
  SERVICE_POD_NAME=""
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
      terminate_usage
      ;;
      *)
      if [[ "$1" == "-"* ]] || [ ! -z "$SERVICE_POD_NAME" ]; then
        error "Unknown argument: ${1}"
        terminate_usage
      fi
      if [ -z "$SERVICE_POD_NAME" ]; then
        SERVICE_POD_NAME="${1}"
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
  if [ $MISSING_ARGS -eq 1 ]; then
    terminate_usage
    exit 1
  fi

  minikube_environment

  debug "Command: terminate"
  debug "> SERVICE_POD_NAME: ${SERVICE_POD_NAME}"
  debug "> SERVICE_NAMESPACE: ${SERVICE_NAMESPACE}"

  if ! minikube_status; then
    emergency "Minikube is not running"
  fi

  kubectl delete pod -n "$SERVICE_NAMESPACE" "$SERVICE_POD_NAME"
  echo ""
}
