#
#=========================================================================================
# <Build> Command
#

function build_description () {
  render "Build Kubernetes development environment artifacts"
}

function build_command_environment () {
  image_build_options

  parse_flag --no-hooks \
    NO_HOOKS \
    "Disable the execution of build hooks for this build"

  parse_optional_args PROJECTS \
    "List of projects to build (defaults to everything)"

  debug "> PROJECTS: ${PROJECTS[@]}"
  debug "> NO_HOOKS: ${NO_HOOKS}"
}

function build_command () {
  save_libraries
  helm_environment

  info "Initializing docker image repositories ..."
  for project in $(config docker); do
    project_reference="$(config docker.$project.project $project)"
    project_dir="${__docker_dir}/${project_reference}"

    if [[ ! "${PROJECTS[*]}" ]] || [[ " ${PROJECTS[*]} " == *" ${project} "* ]]; then
      info "Building ${project} docker image"
      build_docker_image "$project" "$project_dir" "$NO_CACHE"
    fi
  done

  if [ ! "$NO_HOOKS" ]; then
    run_hook build
  fi
  info "Development environment initialization complete"
}
