#
#=========================================================================================
# <Up> Command
#

function up_description () {
  render "Initialize and ensure Minikube development environment is running"
}

function up_command_environment () {
  parse_flag --build \
    BUILD \
    "Build development environment artifacts after startup"

  image_build_options "(requires --build)"
  cert_options

  BUILD_ARGS=()
  if [ "$NO_CACHE" ]; then
    BUILD_ARGS=("${BUILD_ARGS[@]}" "--no-cache")
  fi
  export BUILD_ARGS

  debug "> BUILD ARGS: ${BUILD_ARGS[@]}"
}

function up_command () {
  cert_environment
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

  info "Generating ingress certificates ..."
  generate_certs \
    "${CERT_SUBJECT}/CN=*.${PRIMARY_DOMAIN}" \
    "$CERT_DAYS"

  info "Initializing ArgoCD application repository ..."
  download_git_repo \
    https://github.com/kube-reactor/argocd-apps.git \
    "${__argocd_apps_dir}" \
    "$ARGOCD_APPS_VERSION"

  start_minikube

  if [[ "$BUILD" ]] || [[ ! -f "${__init_file}" ]]; then
    run_command build "${BUILD_ARGS[@]}"
  fi
  touch "${__init_file}"
  run_command update
  run_hook up
}

function up_host_command () {
  launch_host_minikube_tunnel

  run_host_command update
  run_hook up_host
}
