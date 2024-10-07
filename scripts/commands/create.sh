#
#=========================================================================================
# <Create> Command
#

function create_description () {
  echo "Create a new cluster project from a template"
}
function create_usage () {
    cat <<EOF >&2

$(create_description)

Usage:

  kubectl reactor create [flags] [options]

Flags:
${__reactor_core_flags}

    --defaults            Use default parameters for cluster testing (no prompt)

    --directory <str>     Parent project directory (default: current directory)
    --remote <url>        Project template Git remote URL (default: ${DEFAULT_PROJECT_TEMPLATE_REMOTE})
    --reference <str>     Project template Git reference (default: ${DEFAULT_PROJECT_TEMPLATE_REFERENCE})
    --config-file <file>  Configuration values for the project template
    --name <str>          Cookiecutter project_slug value override
    --project <str>       Cookiecutter project directory (alternate to --remote and --reference)

EOF
  exit 1
}
function create_command () {
  PROJECT_DIRECTORY=""
  PROJECT_PARENT_DIRECTORY="./"
  PROJECT_TEMPLATE_CONFIG_FILE=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --defaults)
      USE_DEFAULTS=1
      ;;
      --directory=*)
      PROJECT_PARENT_DIRECTORY="${1#*=}"
      ;;
      --directory)
      PROJECT_PARENT_DIRECTORY="$2"
      shift
      ;;
      --remote=*)
      PROJECT_TEMPLATE_REMOTE="${1#*=}"
      ;;
      --remote)
      PROJECT_TEMPLATE_REMOTE="$2"
      shift
      ;;
      --reference=*)
      PROJECT_TEMPLATE_REFERENCE="${1#*=}"
      ;;
      --reference)
      PROJECT_TEMPLATE_REFERENCE="$2"
      shift
      ;;
      --config-file=*)
      PROJECT_TEMPLATE_CONFIG_FILE="${1#*=}"
      ;;
      --config-file)
      PROJECT_TEMPLATE_CONFIG_FILE="$2"
      shift
      ;;
      --name=*)
      PROJECT_NAME="${1#*=}"
      ;;
      --name)
      PROJECT_NAME="$2"
      shift
      ;;
      --project=*)
      PROJECT_DIRECTORY="${1#*=}"
      ;;
      --project)
      PROJECT_DIRECTORY="$2"
      shift
      ;;
      -h|--help)
      create_usage
      ;;
      *)
      if ! [ -z "$1" ]; then
        error "Unknown argument: ${1}"
        create_usage
      fi
      ;;
    esac
    shift
  done
  export USE_DEFAULTS=${USE_DEFAULTS:-0}
  export PROJECT_PARENT_DIRECTORY
  export PROJECT_TEMPLATE_REMOTE="${PROJECT_TEMPLATE_REMOTE:-$DEFAULT_PROJECT_TEMPLATE_REMOTE}"
  export PROJECT_TEMPLATE_REFERENCE="${PROJECT_TEMPLATE_REFERENCE:-$DEFAULT_PROJECT_TEMPLATE_REFERENCE}"
  export PROJECT_TEMP_DIRECTORY="/tmp/reactor-project"
  export PROJECT_TEMPLATE_CONFIG_FILE
  export PROJECT_NAME
  export PROJECT_DIRECTORY

  debug "Command: create"
  debug "> USE_DEFAULTS: ${USE_DEFAULTS}"
  debug "> PROJECT_PARENT_DIRECTORY: ${PROJECT_PARENT_DIRECTORY}"
  debug "> PROJECT_TEMPLATE_REMOTE: ${PROJECT_TEMPLATE_REMOTE}"
  debug "> PROJECT_TEMPLATE_REFERENCE: ${PROJECT_TEMPLATE_REFERENCE}"
  debug "> PROJECT_TEMPLATE_CONFIG_FILE: ${PROJECT_TEMPLATE_CONFIG_FILE}"
  debug "> PROJECT_NAME: ${PROJECT_NAME}"
  debug "> PROJECT_DIRECTORY: ${PROJECT_DIRECTORY}"

  if [ -d "$PROJECT_TEMP_DIRECTORY" ]; then
    rm -Rf "$PROJECT_TEMP_DIRECTORY"
  fi
  if [ ! -d "$PROJECT_DIRECTORY" ]; then
    info "Fetching cluster template ..."
    download_git_repo \
      "$PROJECT_TEMPLATE_REMOTE" \
      "$PROJECT_TEMP_DIRECTORY" \
      "$PROJECT_TEMPLATE_REFERENCE"
  else
    PROJECT_TEMP_DIRECTORY="$PROJECT_DIRECTORY"
  fi

  TEMPLATE_VARS=(
    "--overwrite-if-exists"
    "--output-dir" "$PROJECT_PARENT_DIRECTORY"
  )
  if [ -f "$PROJECT_TEMPLATE_CONFIG_FILE" ]; then
    TEMPLATE_VARS=("${TEMPLATE_VARS[@]}" "--no-input" "--config-file" "$PROJECT_TEMPLATE_CONFIG_FILE")
  elif [ $USE_DEFAULTS -eq 1 ]; then
    TEMPLATE_VARS=("${TEMPLATE_VARS[@]}" "--no-input")
  fi
  TEMPLATE_VARS=("${TEMPLATE_VARS[@]}" "$PROJECT_TEMP_DIRECTORY")

  if [ ! -z "$PROJECT_NAME" ]; then
    TEMPLATE_VARS=("${TEMPLATE_VARS[@]}" "project_slug=$PROJECT_NAME")
  fi
  info "Creating cluster project ..."
  cookiecutter "${TEMPLATE_VARS[@]}"

  if [ ! -d "$PROJECT_DIRECTORY" ]; then
    rm -Rf "$PROJECT_TEMP_DIRECTORY"
  fi
  exec_hook create
}
