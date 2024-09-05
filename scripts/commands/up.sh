#
#=========================================================================================
# <Up> Command
#

function up_usage () {
    cat <<EOF >&2

Initialize and ensure Minikube development environment is running.

Usage:

  kubectl reactor up [flags] [options]

Flags:
${__reactor_core_flags}

    --init                Initialize the development environment before startup
    --skip-build          Skip Docker image build step (requires --init)
    --no-cache            Regenerate all intermediate images (requires --init)
EOF
  exit 1
}

function up_command () {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --init)
      INITIALIZE=1
      ;;
      --skip-build)
      SKIP_BUILD=1
      ;;
      --no-cache)
      NO_CACHE=1
      ;;
      -h|--help)
      up_usage
      ;;
      *)
      if ! [ -z "$1" ]; then
        error "Unknown argument: ${1}"
        up_usage
      fi
      ;;
    esac
    shift
  done
  INITIALIZE=${INITIALIZE:-0}
  SKIP_BUILD=${SKIP_BUILD:-0}
  NO_CACHE=${NO_CACHE:-0}

  INIT_ARGS=()

  if [ $SKIP_BUILD -ne 0 ]; then
    INIT_ARGS=("${INIT_ARGS[@]}" "--skip-build")
  fi
  if [ $NO_CACHE -ne 0 ]; then
    INIT_ARGS=("${INIT_ARGS[@]}" "--no-cache")
  fi

  debug "Command: up"
  debug "> SKIP_BUILD: ${SKIP_BUILD}"
  debug "> NO_CACHE: ${NO_CACHE}"
  debug "> INITIALIZE: ${INITIALIZE}"
  debug "> INIT ARGS: ${INIT_ARGS[@]}"

  if [[ $INITIALIZE -eq 1 ]]; then
    init_command "${INIT_ARGS[@]}"
  fi

  start_minikube
  #launch_minikube_tunnel

  #update_command

  #launch_minikube_dashboard
}
