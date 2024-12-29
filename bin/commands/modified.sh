#
#=========================================================================================
# <Modified> Command
#

function modified_description () {
  render "Check project repositories for modified files"
}

function modified_command () {
  if [ -d "${__project_dir}/.git" ]; then
    add_line '-'
    info "Checking $(variable_color "${__project_name}") Project repository"
    info ""
    info "Directory: $(variable_color "${__project_dir}")"
    info ""
    add_line '-'
    cd "${__project_dir}"
    git status
  fi

  for project in $(config docker); do
    project_dir="${__docker_dir}/${project}"

    if [ -d "${project_dir}/.git" ]; then
      add_space
      add_line '-'
      info "Checking $(variable_color "${project}") Docker image repository"
      info ""
      info "Directory: $(variable_color "${project_dir}")"
      info ""
      add_line '-'
      cd "$project_dir"
      git status
    fi
  done

  for chart in $(config charts); do
    chart_dir="${__charts_dir}/${chart}"

    if [ -d "${chart_dir}/.git" ]; then
      add_space
      add_line '-'
      info "Checking $(variable_color "${chart}") Helm chart repository"
      info ""
      info "Directory: $(variable_color "${chart_dir}")"
      info ""
      add_line '-'
      cd "$chart_dir"
      git status
    fi
  done

  for extension in $(config extensions); do
    extension_dir="${__extension_dir}/${extension}"

    if [ -d "${extension_dir}/.git" ]; then
      add_space
      add_line '-'
      info "Checking reactor $(variable_color "${extension}") Extension repository"
      info ""
      info "Directory: $(variable_color "${extension_dir}")"
      info ""
      add_line '-'
      cd "$extension_dir"
      git status
    fi
  done

  run_hook modified

  add_space
  info "Repository check complete"
}
