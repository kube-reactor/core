#
#=========================================================================================
# Disk Utilities
#

#
#=========================================================================================
# Logging Utilities
#

function logdir () {
  if check_project; then
    mkdir -p "${__log_dir}"
    echo "${__log_dir}"
  else
    echo "/tmp"
  fi
}

function logfile () {
  if [ "${REACTOR_SHELL_OUTPUT:-}" ]; then
    echo "/dev/stdout"
  else
    echo "$(logdir)/reactor.log"
  fi
}

#
#=========================================================================================
# Installation and Execution Utilities
#

function check_binary () {
  if ! command -v "$1" > /dev/null; then
    emergency "Install binary: \"$1\""
  fi
}

function download_binary () {
  if ! command -v "$3/$1" > /dev/null; then
    debug "Download binary: \"$1\" from url: \"$2\""
    if [[ "$2" == *.tar.gz ]]; then
      curl -sLo "/tmp/$1.tar.gz" "$2" 1>>"$(logfile)" 2>&1
      tar -xzf "/tmp/$1.tar.gz" -C "/tmp" 1>>"$(logfile)" 2>&1
      mv "/tmp/$4/$1" "/tmp/$1" 1>>"$(logfile)" 2>&1
      rm -f "/tmp/$1.tar.gz" 1>>"$(logfile)" 2>&1
      rm -Rf "/tmp/$4" 1>>"$(logfile)" 2>&1
    else
      curl -sLo "/tmp/$1" "$2" 1>>"$(logfile)" 2>&1
    fi
    install "/tmp/$1" "$3" 1>>"$(logfile)" 2>&1
    rm -f "/tmp/$1" 1>>"$(logfile)" 2>&1
    debug "\"$1\" was downloaded install binary into folder: \"$3\""
  fi
}

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

function exec_git ()
{
   DIRECTORY="$1";
   shift;
   echo "Running git ${@} on ${DIRECTORY}" >>"$(logfile)"
   git --git-dir="${DIRECTORY}/.git" --work-tree="${DIRECTORY}" "$@" 1>>"$(logfile)" 2>&1
}

function download_git_repo () {
  URL="$1"
  DIRECTORY="$2"
  REFERENCE="${3:-main}"

  debug "Updating Git repository: ${URL}"
  debug " * into: ${DIRECTORY}"
  debug " * with reference: ${REFERENCE}"

  if [ ! -d "$DIRECTORY" ]; then
    info "Fetching repository \"$URL\" into folder \"$DIRECTORY\" ..."
    git clone --quiet "$URL" "$DIRECTORY" 1>>"$(logfile)" 2>&1
  fi
  exec_git "$DIRECTORY" fetch origin --tags
  exec_git "$DIRECTORY" checkout "$REFERENCE" --
}

#
#=========================================================================================
# Reactor Utilities
#

function update_projects () {
  if check_project; then
    debug "Updating docker image repositories ..."
    for project in $(config docker); do
      project_reference="$(config docker.$project.project $project)"
      project_dir="${__docker_dir}/${project_reference}"
      project_remote="$(config docker.$project_reference.remote)"
      project_reference="$(config docker.$project_reference.reference main)"

      if [ ! -z "$project_remote" ]; then
        debug "Updating ${project} docker image repository"
        download_git_repo \
          "$project_remote" \
          "$project_dir" \
          "$project_reference"
      fi
      if [ -f "${project_dir}/reactor/initialize.sh" ]; then
        source "${project_dir}/reactor/initialize.sh" "$project" "$project_dir"
      fi
    done

    debug "Updating Helm chart repositories ..."
    for chart in $(config charts); do
      chart_reference="$(config charts.$chart.project $chart)"
      chart_dir="${__charts_dir}/${chart_reference}"
      chart_remote="$(config charts.$chart_reference.remote)"
      chart_reference="$(config charts.$chart_reference.reference main)"

      if [ ! -z "$chart_remote" ]; then
        debug "Updating ${chart} Helm chart repository"
        download_git_repo \
          "$chart_remote" \
          "$chart_dir" \
          "$chart_reference"
      fi
      if [ -f "${chart_dir}/reactor/initialize.sh" ]; then
        source "${chart_dir}/reactor/initialize.sh" "$chart" "$chart_dir"
      fi
    done

    debug "Updating extension repositories ..."
    for extension in $(config extensions); do
      extension_dir="${__extension_dir}/${extension}"

      debug "Updating reactor ${extension} repository"
      download_git_repo \
          "$(config extensions.$extension.remote)" \
          "${extension_dir}" \
          "$(config extensions.$extension.reference)"

      if [ -f "${extension_dir}/reactor/initialize.sh" ]; then
        source "${extension_dir}/reactor/initialize.sh" "$extension" "$extension_dir"
      fi
    done
  fi
  run_hook update_projects
  debug "Project updates complete"
}
