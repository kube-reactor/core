#
#=========================================================================================
# <Up> Command
#

function up_description () {
  echo "Initialize and ensure Minikube development environment is running"
}
function up_usage () {
  cat <<EOF >&2

$(up_description)

Usage:

  kubectl reactor up [flags] [options]

Flags:
${__reactor_core_flags}

    --build               Build development environment artifacts after startup
    --no-cache            Regenerate all intermediate images (requires --build)

Options

    --cert-subject <str>  Self signed ingress SSL certificate subject: ${DEFAULT_CERT_SUBJECT}
    --cert-days <int>     Self signed ingress SSL certificate days to expiration: ${DEFAULT_CERT_DAYS}

EOF
  exit 1
}

function up_environment () {
  COMMAND_ARGUMENTS=("$@")
  set -- "${COMMAND_ARGUMENTS[@]}"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --cert-days=*)
      export CERT_DAYS="${1#*=}"
      ;;
      --cert-days)
      export CERT_DAYS="$2"
      shift
      ;;
      --cert-subject=*)
      export CERT_SUBJECT="${1#*=}"
      ;;
      --cert-subject)
      export CERT_SUBJECT="$2"
      shift
      ;;
      --build)
      BUILD=1
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
  export BUILD=${BUILD:-0}
  export NO_CACHE=${NO_CACHE:-0}

  BUILD_ARGS=()
  if [ $NO_CACHE -ne 0 ]; then
    BUILD_ARGS=("${BUILD_ARGS[@]}" "--no-cache")
  fi
  export BUILD_ARGS

  debug "Command: up"
  debug "> BUILD: ${BUILD}"
  debug "> NO_CACHE: ${NO_CACHE}"
  debug "> BUILD ARGS: ${BUILD_ARGS[@]}"
}

function up_command () {
  up_environment "$@"
  cert_environment
  helm_environment

  info "Generating ingress certificates ..."
  generate_certs \
    "${CERT_SUBJECT}/CN=*.${PRIMARY_DOMAIN}" \
    "$CERT_DAYS"

  info "Initializing ArgoCD application repository ..."
  download_git_repo \
    https://github.com/zimagi/argocd-apps.git \
    "${__argocd_apps_dir}"

  start_minikube

  if [[ $BUILD -eq 1 ]]; then
    build_command "${BUILD_ARGS[@]}"
  fi
  update_command
}

function up_host_command () {
  up_environment "$@"
  minikube_environment
  helm_environment

  info "Downloading local software dependencies ..."
  download_binary minikube \
    "https://storage.googleapis.com/minikube/releases/latest/minikube-${__os}-${__architecture}" \
    "${__binary_dir}"

  download_binary kubectl \
    "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${__architecture}/kubectl" \
    "${__binary_dir}"

  download_binary helm \
    "https://get.helm.sh/helm-v${HELM_VERSION}-${__os}-${__architecture}.tar.gz" \
    "${__binary_dir}" \
    "${__os}-${__architecture}"

  download_binary argocd \
    "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-${__os}-${__architecture}" \
    "${__binary_dir}"

  launch_host_minikube_tunnel
  launch_host_minikube_dashboard

  update_host_command
}
