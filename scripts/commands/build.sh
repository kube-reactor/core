#
#=========================================================================================
# <Build> Command
#

function build_description () {
  echo "Build Kubernetes development environment artifacts"
}
function build_usage () {
    cat <<EOF >&2

$(build_description)

Usage:

  kubectl reactor build [flags] [options]

Flags:
${__reactor_core_flags}

    --no-cache            Regenerate all intermediate images

EOF
  exit 1
}
function build_command () {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --no-cache)
      NO_CACHE=1
      ;;
      -h|--help)
      build_usage
      ;;
      *)
      if [[ "$1" == "-"* ]]; then
        error "Unknown argument: ${1}"
        build_usage
      fi
      ;;
    esac
    shift
  done
  NO_CACHE=${NO_CACHE:-0}

  debug "Command: build"
  debug "> NO_CACHE: ${NO_CACHE}"

  helm_environment

  info "Initializing docker image repositories ..."
  for project in $(config docker); do
    info "Initializing ${project} docker image repository"
    download_git_repo \
        "$(config docker.$project.remote)" \
        "${__docker_dir}/${project}" \
        "$(config docker.$project.reference)"

    info "Building ${project} docker image"
    build_docker_image "$project" $NO_CACHE
  done

  info "Initializing Helm chart repositories ..."
  for chart in $(config charts); do
    chart_dir="${__charts_dir}/${chart}"

    info "Initializing ${chart} Helm chart repository"
    download_git_repo \
        "$(config charts.$chart.remote)" \
        "${chart_dir}" \
        "$(config charts.$chart.reference)"
  done
  info "Development environment initialization complete"
}
