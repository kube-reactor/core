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
#    *> reactor create --name {project_name} --url {template_url} # ./projects/{project_name} ./templates/{project_name}
#
#  * Template Development
#
#    -> When File Exists: ./cookiecutter.json
#
#    *> git clone {template_git_url} {template_directory}
#    *> cd {template_directory}
#    *> reactor create --name {project_name} # ./{project_name}
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
  parse_option --name \
    PROJECT_NAME \
    "Cookiecutter project_slug value override" \
    "${__project_name}"

  if ! check_template && ! check_core; then
    parse_option --directory \
      PROJECT_PARENT_DIRECTORY \
      "Parent project directory" \
      "$(pwd)"
  fi
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

    export TEMPLATES_DIRECTORY="${__templates_dir}"
    mkdir -p "$TEMPLATES_DIRECTORY"

    export TEMPLATE_DIRECTORY="${TEMPLATES_DIRECTORY}/${PROJECT_NAME}"

    if check_core; then
      # Core exists
      export PROJECT_PARENT_DIRECTORY="${__projects_dir}"
      mkdir -p "$PROJECT_PARENT_DIRECTORY"
    fi
  else
    # Template exists
    export TEMPLATE_DIRECTORY="${__template_dir}"
    export PROJECT_PARENT_DIRECTORY="${TEMPLATE_DIRECTORY}"
  fi

  export PROJECT_DIRECTORY="${PROJECT_PARENT_DIRECTORY}/${PROJECT_NAME}"

  parse_flag --defaults \
    USE_DEFAULTS \
    "Use default parameters for cluster testing (no prompt)"

  parse_option --config-file \
    PROJECT_TEMPLATE_CONFIG_FILE \
    "Configuration values for the project template"
}

function create_command () {
  if check_project; then
    emergency "You cannot create a new project while in the context of an existing project"
  fi
  if [ -d "$PROJECT_DIRECTORY" ]; then
    emergency "Can not create project ${PROJECT_NAME} because project directory already exists"
  fi

  cookiecutter_bin="$(find ~ -name cookiecutter 2>/dev/null | grep -m 1 "/bin/")"
  project_temp_dir="/tmp/reactor/download"

  info "Fetching cluster template ..."
  download_git_repo \
    "$PROJECT_URL" \
    "$project_temp_dir" \
    "$PROJECT_REFERENCE"

  if [ -f "${project_temp_dir}/reactor.yml" ]; then
    mv "$project_temp_dir" "$PROJECT_DIRECTORY"
  elif [ ! -d "$TEMPLATE_DIRECTORY" ]; then
    mv "$project_temp_dir" "$TEMPLATE_DIRECTORY"
  else
    rm -Rf "$project_temp_dir"
  fi

  if [ -d "$TEMPLATE_DIRECTORY" ]; then
    cd "$TEMPLATE_DIRECTORY"
    git fetch "$PROJECT_REMOTE"
    git checkout "$PROJECT_REFERENCE"

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
      "project_slug=${PROJECT_NAME}"
    )
    info "Creating cluster project ..."
    "$cookiecutter_bin" "${TEMPLATE_VARS[@]}"
  fi
  run_hook create
}
