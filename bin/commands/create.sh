#
#=========================================================================================
# <Create> Command
#

#
# Development Modes
#
#  * Core Development
#
#    -> When File Exists: ./reactor.template.yaml
#
#    *> git clone https://github.com/kube-reactor/core.git {core_directory}
#    *> cd {core_directory}
#    *> reactor create {project_name} --url {template_url} # ./projects/{project_name} ./templates/{project_name}
#
#  * Template Development
#
#    -> When File Exists: ./cookiecutter.json
#
#    *> git clone {template_git_url} {template_directory}
#    *> cd {template_directory}
#    *> reactor create {project_name} # ./{project_name}
#
#  * Project Development
#
#    -> When File Exists: ./reactor.yml
#
#    *> git clone {project_git_url} {project_directory}
#    *> cd {project_directory}
#    *> reactor template --name {template_name} # ./
#

# Create parameters:
#
# 0. None if within project and no core or template
# 1. {project_name} if within template
# 2. {project_name} and {project_url} if within core or no context

# Development Mode priority:
#
# * project (none)
# * template - Create new project from existing template (project name)
# * core - Create new template and project from template url
# |(or)
# * core - Create new project from project url
# * no context - Create new template and project from template url
# |(or)
# * no context - Create new project from project url
#

function create_description () {
  render "Create a new cluster project from a template (not available within projects)"
}

function create_requires_project () {
  return 1
}

function create_command_environment () {
  force_option

  parse_flag --rebuild \
    PROJECT_REBUILD \
    "Clean and rebuild project (VERY destructive)"

  if check_core; then
    export PROJECT_PARENT_DIRECTORY="${__projects_dir}"
  elif check_template; then
    export PROJECT_PARENT_DIRECTORY="${__template_dir}"
  else
    export PROJECT_PARENT_DIRECTORY="$(pwd)"
  fi

  parse_option --directory \
    PROJECT_PARENT_DIRECTORY \
    "Parent project directory" \
    "$PROJECT_PARENT_DIRECTORY"

  if ! check_template; then
    parse_option --url \
      PROJECT_URL \
      "Project template Git remote URL" \
      "$DEFAULT_PROJECT_URL"

    parse_option --remote \
      PROJECT_REMOTE \
      "Test project Git remote name to fetch (when repository exists)" \
      "$DEFAULT_PROJECT_REMOTE"

    parse_option --reference \
      PROJECT_REFERENCE \
      "Project template Git reference" \
      "$DEFAULT_PROJECT_REFERENCE"
  fi

  parse_flag --ignore \
    IGNORE_EXISTS \
    "Return immediately without error if project exists instead default behavior of erroring"

  parse_flag --defaults \
    USE_DEFAULTS \
    "Use default parameters for cluster testing (no prompt)"

  parse_option --config-file \
    PROJECT_TEMPLATE_CONFIG_FILE \
    "Configuration values for the project template"

  parse_arg PROJECT_NAME \
    "Cookiecutter project key (must contain only alpha-numeric characters and underscores)"

  export PROJECT_NAME="${PROJECT_NAME//[-.]/_}"

  if ! check_template; then
    export TEMPLATES_DIRECTORY="${__templates_dir}"
    mkdir -p "$TEMPLATES_DIRECTORY"

    export TEMPLATE_DIRECTORY="${TEMPLATES_DIRECTORY}/${PROJECT_NAME}"

    if check_core; then
      mkdir -p "$PROJECT_PARENT_DIRECTORY"
    fi
  else
    export TEMPLATE_DIRECTORY="${__template_dir}"
  fi

  export PROJECT_DIRECTORY="${PROJECT_PARENT_DIRECTORY}/${PROJECT_NAME}"
}

function create_command () {
  project_temp_dir="/tmp/reactor/download"

  if check_project; then
    emergency "You cannot create a new project while in the context of an existing project"
  fi
  if [[ "$PROJECT_REBUILD" ]] && [[ ! "$FORCE" ]]; then
    render "The --rebuild option will completely destroy all project files before creating again"
    confirm
  fi

  if [ ! "$PROJECT_REBUILD" ]; then
    if [ -d "$PROJECT_DIRECTORY" ]; then
      if [ "$IGNORE_EXISTS" ]; then
        info "Project exists: skipping create"
        exit 0
      else
        emergency "Can not create project ${PROJECT_NAME} because project directory already exists"
      fi
    fi
  else
    rm -Rf "$PROJECT_DIRECTORY"
  fi

  if [ ! -d "$TEMPLATE_DIRECTORY" ]; then
    rm -Rf "$project_temp_dir"

    info "Fetching cluster template ..."
    download_git_repo \
      "$PROJECT_URL" \
      "$project_temp_dir" \
      "$PROJECT_REFERENCE"

    if [ -f "${project_temp_dir}/reactor.yml" ]; then
      # Reactor Project
      mv "$project_temp_dir" "$PROJECT_DIRECTORY"
    else
      # Reactor Template
      mv "$project_temp_dir" "$TEMPLATE_DIRECTORY"
    fi
  fi

  if [ -d "$TEMPLATE_DIRECTORY" ]; then
    cd "$TEMPLATE_DIRECTORY"

    if check_core && [ "${PROJECT_REMOTE:-}" -a "${PROJECT_REFERENCE:-}" ]; then
      git fetch "$PROJECT_REMOTE"
      git checkout "$PROJECT_REFERENCE"
    fi

    TEMPLATE_VARS=(
      "--overwrite-if-exists"
      "--output-dir" "$PROJECT_PARENT_DIRECTORY"
    )
    if [ -f "$PROJECT_TEMPLATE_CONFIG_FILE" ]; then
      TEMPLATE_VARS=(
        "${TEMPLATE_VARS[@]}"
        "--no-input"
        "--config-file" "$PROJECT_TEMPLATE_CONFIG_FILE"
      )
    elif [ "$USE_DEFAULTS" ]; then
      TEMPLATE_VARS=("${TEMPLATE_VARS[@]}" "--no-input")
    fi
    TEMPLATE_VARS=(
      "${TEMPLATE_VARS[@]}"
      "$TEMPLATE_DIRECTORY"
      "__project_key=${PROJECT_NAME}"
    )
    info "Creating cluster project ..."
    cookiecutter "${TEMPLATE_VARS[@]}"
  fi

  if [ ! -f "${PROJECT_DIRECTORY}/reactor.yml" ]; then
    emergency "No valid project created: ${PROJECT_DIRECTORY}"
  fi

  run_hook create
}
