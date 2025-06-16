#
#=========================================================================================
# Disk Utilities
#

#
#=========================================================================================
# Folder and File Utilities
#

function create_folder () {
  if ! [ -d "$1" ]; then
    debug "Create folder \"$1\""
    mkdir -p "$1" 1>>"$(logfile)" 2>&1
  fi
}

function remove_folder () {
  if [ -d "$1" ]; then
    debug "Removing folder \"$1\""
    rm -Rf "$1" 1>>"$(logfile)" 2>&1
  fi
}

function remove_file () {
  if [ -f "$1" ]; then
    debug "Removing file \"$1\""
    rm -f "$1" 1>>"$(logfile)" 2>&1
  fi
}

function clean_cache () {
  sudo rm -Rf "${__cache_dir}"
}

#
#=========================================================================================
# Git Utilities
#

function exec_git () {
  DIRECTORY="$1";
  shift;
  git --git-dir="${DIRECTORY}/.git" --work-tree="${DIRECTORY}" "$@" 1>>"$(logfile)" 2>&1
}

function update_git_repo () {
  DIRECTORY="$1"
  REFERENCE="${2:-main}"

  if [ -d "${DIRECTORY}/.git" ]; then
    debug "Updating Git repository: ${DIRECTORY}"
    debug " * with reference: ${REFERENCE}"

    exec_git "$DIRECTORY" fetch origin --tags 1>>"$(logfile)" 2>&1
    exec_git "$DIRECTORY" checkout "$REFERENCE" -- 1>>"$(logfile)" 2>&1

    if exec_git "$DIRECTORY" show-ref --verify "refs/heads/${REFERENCE}" >/dev/null 2>&1; then
      exec_git "$DIRECTORY" pull origin "$REFERENCE" 1>>"$(logfile)" 2>&1
    fi
  fi
}

function download_git_repo () {
  URL="$1"
  DIRECTORY="$2"
  REFERENCE="${3:-main}"

  if [ ! -d "$DIRECTORY" ]; then
    info "Fetching repository \"$URL\" into folder \"$DIRECTORY\" ..."
    git clone --quiet "$URL" "$DIRECTORY" 1>>"$(logfile)" 2>&1
  fi
  update_git_repo "$DIRECTORY" "$REFERENCE"
}

#
#=========================================================================================
# Reactor Utilities
#

function update_projects () {
  if check_project; then
    debug "Updating extension repositories ..."
    for extension in $(config extensions); do
      extension_dir="${__repo_dir}/$(config extensions.$extension.directory $extension)"
      extension_remote="$(config extensions.$extension.remote)"
      extension_reference="$(config extensions.$extension.reference main)"

      if [ "$extension_remote" ]; then
        debug "Updating reactor ${extension} repository"
        download_git_repo \
          "${extension_remote}" \
          "${extension_dir}" \
          "${extension_reference}"
      fi
    done
  fi
  save_libraries

  run_hook update_projects
  debug "Project updates complete"
}
