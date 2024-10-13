#
#=========================================================================================
# <Create> Command
#

function create_description () {
  echo "Create a new cluster project from a template"
}

function create_command_environment () {
  parse_flag --defaults \
    USE_DEFAULTS \
    "Use default parameters for cluster testing (no prompt)"

  parse_option --directory \
    PROJECT_PARENT_DIRECTORY \
    "Parent project directory" \
    "$(pwd)"

  parse_option --remote \
    PROJECT_TEMPLATE_REMOTE \
    "Project template Git remote URL" \
    "$DEFAULT_PROJECT_TEMPLATE_REMOTE"

  parse_option --reference \
    PROJECT_TEMPLATE_REFERENCE \
    "Project template Git reference" \
    "$DEFAULT_PROJECT_TEMPLATE_REFERENCE"

  parse_option --config-file \
    PROJECT_TEMPLATE_CONFIG_FILE \
    "Configuration values for the project template"

  parse_option --name \
    PROJECT_NAME \
    "Cookiecutter project_slug value override"

  parse_option --project \
    PROJECT_DIRECTORY \
    "Cookiecutter project directory (alternate to --remote and --reference)"
}

function create_command () {
  export PROJECT_TEMP_DIRECTORY="/tmp/reactor-project"

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
  elif [ "$USE_DEFAULTS" ]; then
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
