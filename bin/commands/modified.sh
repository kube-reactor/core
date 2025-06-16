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

  declare -A processed

  for docker in $(config docker); do
    project_reference="$(config docker.$docker.project $docker)"
    project_dir="${__repo_dir}/${project_reference}"
    if [[ -z "${processed["$project_dir"]}" ]]; then
      check_git_status "docker" "${docker}" "${project_dir}"
    fi
    processed["$project_dir"]=1
  done
  for chart in $(config charts); do
    project_reference="$(config charts.$chart.project $chart)"
    project_dir="${__repo_dir}/${project_reference}"
    if [[ -z "${processed["$project_dir"]}" ]]; then
      check_git_status "chart" "${chart}" "${project_dir}"
    fi
    processed["$project_dir"]=1
  done
  for extension in $(config extensions); do
    project_reference="$(config extensions.$extension.project $extension)"
    project_dir="${__repo_dir}/${project_reference}"
    if [[ -z "${processed["$project_dir"]}" ]]; then
      check_git_status "extension" "${extension}" "${project_dir}"
    fi
    processed["$project_dir"]=1
  done

  run_hook modified

  add_space
  info "Repository check complete"
}
