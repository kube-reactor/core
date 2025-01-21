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

function exec_git ()
{
   DIRECTORY="$1";
   shift;
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
