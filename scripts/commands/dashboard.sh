#
#=========================================================================================
# <Dashboard> Command
#

function dashboard_description () {
  echo "Launch the Kubernetes Dashboard for the Minikube cluster"
}
function dashboard_usage () {
    cat <<EOF >&2

$(dashboard_description)

Usage:

  kubectl reactor dashboard [flags] [options]

Flags:
${__reactor_core_flags}

EOF
  exit 1
}
function dashboard_command () {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
      dashboard_usage
      ;;
      *)
      if ! [ -z "$1" ]; then
        error "Unknown argument: ${1}"
        dashboard_usage
      fi
      ;;
    esac
    shift
  done

  launch_minikube_dashboard
}
