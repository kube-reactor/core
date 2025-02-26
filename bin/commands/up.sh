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

  parse_flag --plan \
    PROVISIONER_PLAN \
    "Output a plan for building the platform instead of deploying"

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

  start_kubernetes

  if [ "${__environment}" == "local" ]; then
    if [[ "$BUILD" ]] || [[ ! -f "${__init_file}" ]]; then
      run_subcommand build "${BUILD_ARGS[@]}"
    fi
  fi
  touch "${__init_file}"

  launch_kubernetes_tunnel
  run_subcommand update
  run_hook up
}
