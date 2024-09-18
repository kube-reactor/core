#
#=========================================================================================
# <Shell> Command
#

function shell_description () {
  echo "Open a terminal session to a running Minikube service"
}
function shell_usage () {
    cat <<EOF >&2

$(shell_description)

Usage:

  kubectl reactor shell [flags] [options] [<service_pod_name:str>]

Flags:
${__reactor_core_flags}

    --namespace           Kubernetes namespace
EOF
  exit 1
}
function shell_command () {
  SERVICE_POD_NAME=""
  SERVICE_NAMESPACE="default"
  SERVICE_COMMAND=()

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
      shell_usage
      ;;
      *)
      if [ -z "$SERVICE_POD_NAME" ]; then
        SERVICE_POD_NAME="${1}"
      else
        SERVICE_COMMAND=("${SERVICE_COMMAND[@]}" "${1}")
      fi
      ;;
    esac
    shift
  done

  if [ -z "$SERVICE_POD_NAME" ]; then
    alert "Service pod name argument required"
    launch_usage
    exit 1
  fi
  if [ ${#SERVICE_COMMAND[@]} -eq 0 ]; then
    SERVICE_COMMAND=("bash")
  fi

  minikube_environment

  debug "Command: shell"
  debug "> SERVICE_POD_NAME: ${SERVICE_POD_NAME}"
  debug "> SERVICE_NAMESPACE: ${SERVICE_NAMESPACE}"
  debug "> SERVICE_COMMAND: ${SERVICE_COMMAND[@]}"

  if ! minikube_status; then
    emergency "Minikube is not running"
  fi
  "${__binary_dir}/kubectl" exec -n "$SERVICE_NAMESPACE" -ti "$SERVICE_POD_NAME" -- "${SERVICE_COMMAND[@]}"
}
