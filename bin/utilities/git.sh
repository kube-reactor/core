#
#=========================================================================================
# Command Execution Utilities
#


function check_git_status () {
  local type="$1"
  local project="$2"
  local project_dir="$3"

  if [ -d "${project_dir}/.git" ]; then
    cd "$project_dir"

    if ! git status 2>&1 | grep "nothing to commit, working tree clean" >/dev/null 2>&1; then
      add_space
      add_line '-'
      info "Checking $(variable_color "${project}") ${type} repository"
      info ""
      info "Directory: $(variable_color "${project_dir}")"
      info ""
      add_line '-'

      git status
    fi
  fi
}