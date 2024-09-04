#
#=========================================================================================
# <Init> Command
#

function init_usage () {
    cat <<EOF >&2

Initialize Kubernetes development environment.

Usage:

  kubectl reactor init [flags] [options]

Flags:
${__reactor_core_flags}

    --skip-build          Skip Docker image build step
    --no-cache            Regenerate all intermediate images
    --no-update           Disable the cluster image update

Options:

    --cert-subject <str>  Self signed ingress SSL certificate subject: ${DEFAULT_CERT_SUBJECT}
    --cert-days <int>     Self signed ingress SSL certificate days to expiration: ${DEFAULT_CERT_DAYS}

EOF
  exit 1
}
function init_command () {
  APP_NAME=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --cert-days=*)
      CERT_DAYS="${1#*=}"
      ;;
      --cert-days)
      CERT_DAYS="$2"
      shift
      ;;
      --cert-subject=*)
      CERT_SUBJECT="${1#*=}"
      ;;
      --cert-subject)
      CERT_SUBJECT="$2"
      shift
      ;;
      --skip-build)
      SKIP_BUILD=1
      ;;
      --no-cache)
      NO_CACHE=1
      ;;
      --no-update)
      NO_UPDATE=1
      ;;
      -h|--help)
      init_usage
      ;;
      *)
      if [[ "$1" == "-"* ]]; then
        error "Unknown argument: ${1}"
        init_usage
      fi
      ;;
    esac
    shift
  done
  SKIP_BUILD=${SKIP_BUILD:-0}
  NO_CACHE=${NO_CACHE:-0}
  NO_UPDATE=${NO_UPDATE:-0}
  CERT_SUBJECT="${CERT_SUBJECT:-$DEFAULT_CERT_SUBJECT}"
  CERT_DAYS="${CERT_DAYS:-$DEFAULT_CERT_DAYS}"
  HELM_VERSION="${HELM_VERSION:-$DEFAULT_HELM_VERSION}"

  debug "Command: init"
  debug "> APP_NAME: ${APP_NAME}"
  debug "> SKIP_BUILD: ${SKIP_BUILD}"
  debug "> NO_CACHE: ${NO_CACHE}"
  debug "> NO_UPDATE: ${NO_UPDATE}"
  debug "> CERT_SUBJECT: ${CERT_SUBJECT}"
  debug "> CERT_DAYS: ${CERT_DAYS}"

  info "Checking development software requirements ..."
  check_binary python 1>>"$(logfile)" 2>&1
  check_binary docker 1>>"$(logfile)" 2>&1
  check_binary git 1>>"$(logfile)" 2>&1
  check_binary curl 1>>"$(logfile)" 2>&1
  check_binary openssl 1>>"$(logfile)" 2>&1

  info "Downloading required Python extensions ..."
  python -m pip install -r "${__reactor_dir}/requirements.txt" 1>>"$(logfile)" 2>&1

  if [ -f "${__project_dir}/requirements.txt" ]; then
    python -m pip install -r "${__project_dir}/requirements.txt" 1>>"$(logfile)" 2>&1
  fi

  info "Downloading local software dependencies ..."
  download_binary minikube \
    "https://storage.googleapis.com/minikube/releases/latest/minikube-${__os}-${__architecture}" \
    "${__binary_dir}"

  download_binary helm \
    "https://get.helm.sh/helm-v${HELM_VERSION}-${__os}-${__architecture}.tar.gz" \
    "${__binary_dir}" \
    "${__os}-${__architecture}"

  download_binary argocd \
    "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-${__os}-${__architecture}" \
    "${__binary_dir}"

  info "Initializing ArgoCD application repository ..."
  download_git_repo https://github.com/zimagi/argocd-apps.git "${__argocd_apps_dir}"

  info "Generating ingress certificates ..."
  generate_certs \
    "${CERT_SUBJECT}/CN=*.$(echo "$APP_NAME" | tr '_' '-').local" \
    "$CERT_DAYS"

  info "Initializing docker image repositories ..."
  for project in $(config docker); do
    download_git_repo \
        "$(config docker.$project.remote)" \
        "${__docker_dir}/${project}" \
        "$(config docker.$project.reference)"

    if [ $SKIP_BUILD -ne 1 ]; then
      build_docker_image "$project" $NO_CACHE
    fi
  done

  info "Initializing Helm chart repositories ..."
  for chart in $(config charts); do
    chart_dir="${__charts_dir}/${chart}"

    download_git_repo \
        "$(config charts.$chart.remote)" \
        "${chart_dir}" \
        "$(config charts.$chart.reference)"
  done

#   if [ $NO_UPDATE -eq 0 ]; then
#     update_command --image
#   fi

  info "Zimagi development environment initialization complete"
}
