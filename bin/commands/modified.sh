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

  for extension in $(config extensions); do
    project_dir="${__repo_dir}/$(config extensions.$extension.directory $extension)"
    check_git_status "extension" "${extension}" "${project_dir}"
  done
  run_hook modified

  add_space
  info "Repository check complete"
}
