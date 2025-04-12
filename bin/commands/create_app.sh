#
#=========================================================================================
# <Create App> Command
#

function create_app_description () {
  render "Create a new application project from a template"
}

function create_app_command_environment () {
  force_option

  parse_flag --rebuild \
    APP_REBUILD \
    "Clean and rebuild project (VERY destructive)"

  parse_option --project \
    APP_PARENT_PROJECT \
    "Application parent project" \
    "${DEFAULT_APP_PARENT_PROJECT:-platform}"

  if [ "${DEFAULT_APP_URL:-}" ]; then
    parse_option --url \
      APP_URL \
      "Application template Git remote URL" \
      "$DEFAULT_APP_URL"
  fi

  parse_option --reference \
    APP_REFERENCE \
    "Application template Git reference" \
    "${DEFAULT_APP_REFERENCE:-main}"

  parse_option --gh-repo \
    GITHUB_REPO \
    "GitHub Repository (defaults to project name)"

  parse_flag --ignore \
    IGNORE_EXISTS \
    "Return immediately without error if application exists instead default behavior of erroring"

  parse_flag --defaults \
    USE_DEFAULTS \
    "Use default parameters for application project (no prompt)"

  parse_option --config-file \
    PROJECT_TEMPLATE_CONFIG_FILE \
    "Configuration values for the project template"

  parse_arg PROJECT_NAME \
    "Cookiecutter project_slug value override (must contain only alpha-numeric characters and underscores)"

  if [ ! "${DEFAULT_APP_URL:-}" ]; then
    parse_arg APP_URL \
      "Application template Git remote URL"
  fi

  if [ ! "${GITHUB_REPO:-}" ]; then
    export GITHUB_REPO="$PROJECT_NAME"
  fi
  if [ "${GITHUB_ORG:-}" ]; then
    export GITHUB_PROJECT="${GITHUB_ORG}/${GITHUB_REPO}"
  fi

  export DOCKER_PARENT_DIRECTORY="${__project_dir}/docker"
  export DOCKER_DIRECTORY="${DOCKER_PARENT_DIRECTORY}/${PROJECT_NAME}"
  export PROJECT_PARENT_DIRECTORY="${__project_dir}/projects/${APP_PARENT_PROJECT}"
  export PROJECT_DIRECTORY="${PROJECT_PARENT_DIRECTORY}/${PROJECT_NAME}"
}

function create_app_command () {
  app_temp_dir="/tmp/reactor/download"

  rm -Rf "$app_temp_dir"
  mkdir -p "${PROJECT_PARENT_DIRECTORY}"

  if [[ "$APP_REBUILD" ]] && [[ ! "$FORCE" ]]; then
    render "The --rebuild option will completely destroy all project files before creating again"
    confirm
  fi
  if [ "$APP_REBUILD" ]; then
    rm -Rf "$DOCKER_DIRECTORY"
    rm -Rf "$PROJECT_DIRECTORY"
  fi

  info "Fetching application template ..."
  download_git_repo \
    "$APP_URL" \
    "$app_temp_dir" \
    "$APP_REFERENCE"

  TEMPLATE_VARS=(
    "--overwrite-if-exists"
    "--output-dir" "$DOCKER_PARENT_DIRECTORY"
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
    "$app_temp_dir"
    "project_slug=${PROJECT_NAME}"
  )
  info "Creating application docker project ..."
  cookiecutter "${TEMPLATE_VARS[@]}"

  if [ -f "${DOCKER_DIRECTORY}/reactor/initialize.sh" ]; then
    source "${DOCKER_DIRECTORY}/reactor/initialize.sh"
  fi
  if [ ! -d "${DOCKER_DIRECTORY}/.git" ]; then
    info "Initializing Git repository ..."
    cd "$DOCKER_DIRECTORY"
    git init
    git add .
    git commit -m "Initial commit."
    git tag 0.1.0
  else
    cd "$DOCKER_DIRECTORY"
  fi

  if [[ "${GITHUB_TOKEN:-}" ]] && [[ "${GITHUB_ORG:-}" ]]; then
    export GITHUB_REMOTE_URL="git@github.com:${GITHUB_PROJECT}.git"

    info "Creating GitHub repository ..."
    if gh repo view "$GITHUB_PROJECT" 1>/dev/null 2>&1; then
      rm -Rf "${DOCKER_DIRECTORY}/.git"
      emergency "Repository ${GITHUB_PROJECT} already exists. Please choose another name"
    fi
    gh repo create "$GITHUB_PROJECT" --private --source="$DOCKER_DIRECTORY" --push

    git remote rm origin
    git remote add origin "$GITHUB_REMOTE_URL"
    git push --tags origin

    add_docker_project \
      "$PROJECT_NAME" \
      "$GITHUB_REMOTE_URL" \
      "$(git var GIT_DEFAULT_BRANCH)" \
      "${APP_DOCKER_DEV_DIR:-docker}" \
      "${APP_DOCKER_DEV_TAG:-dev}"
  fi

  if [ -d "${__project_dir}/env/prod" ]; then
    source "${__project_dir}/env/prod/public.sh"
  fi
  export CLUSTER_PROJECT_DIRECTORY="${DOCKER_DIRECTORY}/reactor/cluster/${KUBERNETES_PROVIDER:-minikube}"

  if [[ -d "$CLUSTER_PROJECT_DIRECTORY" ]] && [[ ! -d "$PROJECT_DIRECTORY" ]]; then
    info "Creating cluster ${APP_PARENT_PROJECT} project ..."
    cp -Rf "$CLUSTER_PROJECT_DIRECTORY" "$PROJECT_DIRECTORY"
  fi

  save_libraries
  run_hook create_app
}
