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

    info "Building ${project} docker image"
    build_docker_image "$project" "$project_dir" "$NO_CACHE"
  done

  run_hook build
  info "Development environment initialization complete"
}
