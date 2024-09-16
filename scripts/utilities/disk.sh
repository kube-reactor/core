#
#=========================================================================================
# File Handling Utilities
#

function logfile () {
    echo "${__log_dir}/${__log_file}.log"
}

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
    exec_git "$DIRECTORY" fetch origin --tags
    exec_git "$DIRECTORY" checkout "$REFERENCE"
  else
    exec_git "$DIRECTORY" fetch origin --tags
  fi
}

function clean_cache () {
  sudo rm -Rf "${__cache_dir}"
}
