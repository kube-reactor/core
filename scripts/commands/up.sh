#
#=========================================================================================
# <Up> Command
#

function up_description () {
  render "Initialize and ensure Kubernetes environment is running"
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
  kubernetes_environment
  helm_environment

  info "Downloading local software dependencies ..."
  install_kubernetes
  run_hook up_install

  info "Generating ingress certificates ..."
  generate_certs \
    "${CERT_SUBJECT}/CN=*.${PRIMARY_DOMAIN}" \
    "$CERT_DAYS"

  info "Initializing ArgoCD application repository ..."
  download_git_repo \
    https://github.com/kube-reactor/argocd-apps.git \
    "${__argocd_apps_dir}" \
    "$ARGOCD_APPS_VERSION"

  start_kubernetes

  if [[ "$BUILD" ]] || [[ ! -f "${__init_file}" ]]; then
    run_command build "${BUILD_ARGS[@]}"
  fi
  touch "${__init_file}"
  run_command update
  run_hook up
}

function up_host_command () {
  launch_host_kubernetes_tunnel

  run_host_command update
  run_hook up_host
}
