#
#=========================================================================================
# <Modified> Command
#

function modified_description () {
  render "Check project repositories for modified files"
}

function modified_command () {
  check_git_status "project" "${__project_name}" "${__project_dir}"
  check_git_status "provisioner" "argocd-apps" "${__argocd_apps_dir}"

  for project in $(config docker); do
    check_git_status "docker" "${project}" "${__docker_dir}/${project}"
  done
  for chart in $(config charts); do
    check_git_status "chart" "${chart}" "${__charts_dir}/${chart}"
  done
  for extension in $(config extensions); do
    check_git_status "extension" "${extension}" "${__extension_dir}/${extension}"
  done

  run_hook modified

  add_space
  info "Repository check complete"
}
