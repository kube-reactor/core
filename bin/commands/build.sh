#
#=========================================================================================
# <Build> Command
#

function build_description () {
  render "Build Kubernetes development environment artifacts"
}

function build_command_environment () {
  image_build_options
}

function build_command () {
  helm_environment

  info "Initializing docker image repositories ..."
  for project in $(config docker); do
    project_reference="$(config docker.$project.project $project)"
    project_dir="${__docker_dir}/${project_reference}"
    project_remote="$(config docker.$project_reference.remote)"
    project_reference="$(config docker.$project_reference.reference main)"

    if [ ! -z "$project_remote" ]; then
      info "Initializing ${project} docker image repository"
      download_git_repo \
        "$project_remote" \
        "$project_dir" \
        "$project_reference"
    fi
    if [ -f "${project_dir}/reactor/initialize.sh" ]; then
      source "${project_dir}/reactor/initialize.sh" "$project" "$project_dir"
    fi
    info "Building ${project} docker image"
    build_docker_image "$project" "$project_dir" "$NO_CACHE"
  done

  info "Initializing Helm chart repositories ..."
  for chart in $(config charts); do
    chart_reference="$(config charts.$chart.project $chart)"
    chart_dir="${__charts_dir}/${chart_reference}"
    chart_remote="$(config charts.$chart_reference.remote)"
    chart_reference="$(config charts.$chart_reference.reference main)"

    if [ ! -z "$chart_remote" ]; then
      info "Initializing ${chart} Helm chart repository"
      download_git_repo \
        "$chart_remote" \
        "$chart_dir" \
        "$chart_reference"
    fi
    if [ -f "${chart_dir}/reactor/initialize.sh" ]; then
      source "${chart_dir}/reactor/initialize.sh" "$project" "$chart_dir"
    fi
  done

  info "Initializing extension repositories ..."
  for extension in $(config extensions); do
    extension_dir="${__extension_dir}/${extension}"

    info "Initializing reactor ${extension} repository"
    download_git_repo \
        "$(config extensions.$extension.remote)" \
        "${extension_dir}" \
        "$(config extensions.$extension.reference)"
  done

  run_hook build
  info "Development environment initialization complete"
}
