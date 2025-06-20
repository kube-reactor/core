#
#=========================================================================================
# Command Environment Utilities
#

function render_overview () {
  debug ""
  debug "Script properties"
  debug "======================================"
  debug "> OS name: ${__os:-}"
  debug "> OS type: ${__os_type:-}"
  debug "> OS distribution: ${__os_dist:-}"
  debug "> CPU arch: ${__architecture:-}"
  debug "> Reactor directory: ${__reactor_dir:-}"
  debug "> Script directory: ${__bin_dir:-}"
  debug ""

  debug "Project and development properties"
  debug "======================================"
  debug "> Project directory: ${__project_dir:-}"
  debug "> Project manifest: ${__project_manifest:-}"
  debug "> Certificate directory: ${__certs_dir:-}"
  debug "> Executable directory: ${__bin_dir:-}"
  debug "> Project repository root directory: ${__repo_dir:-}"
  debug "> Terraform project root directory: ${__terraform_dir:-}"
  debug ""

  run_hook render_overview
}

function current_environment () {
  ENVIRONMENT_VARS=()

  while IFS= read -r variable; do
    if [[ "$variable" != "HOSTNAME" ]] \
      && [[ "$variable" != "PATH" ]] \
      && [[ "$variable" != "PWD" ]] \
      && [[ "$variable" != "USER" ]] \
      && [[ "$variable" != "HOME" ]] \
      && [[ "$variable" != "SHELL" ]] \
      && [[ "$variable" != "BASH_"* ]] \
      && [[ "$variable" != "SCRIPT_"* ]] \
      && [[ "$variable" != "REACTOR_DIR" ]] \
      && [[ "$variable" != "SHARE_DIR" ]]; then

      ENVIRONMENT_VARS=("${ENVIRONMENT_VARS[@]}" "$variable")
    fi
  done <<< "$(env | grep -Po "[_A-Z0-9]{3,}=" | sed 's/\=//')"

  echo "${ENVIRONMENT_VARS[@]}"
}

function render_environment () {
  for variable in $(current_environment); do
    if [[ "$variable" != "COLOR_"* ]]; then
      echo "${variable}: $(eval "echo \"\$${variable}\"" 2>/dev/null)"
    fi
  done
}

function parse_environment () {
  local command="$1"
  local environment_function="${command}_command_environment"

  if function_exists "$environment_function"; then
    "$environment_function"
  fi
  if [ "${__reactor_arg_errors}" ]; then
    command_usage "$command"
    render_overview
    exit 1
  fi
  render_overview
}