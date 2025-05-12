#
#=========================================================================================
# <Template> Command
#

#
# Development Modes
#
#  * Project Development
#
#    -> When File Exists: ./reactor.yml
#
#    *> git clone {project_git_url} {project_directory}
#    *> cd {project_directory}
#    *> reactor template --name {template_name} # ./
#

# Template parameters:
#
# 0. None if not within project
# 1. {template_name} if within project

# Development Mode priority:
#
# * project (Create or update existing template)
#

function template_description () {
  render "Create or update a cluster template from a project (must be within projects)"
}

function template_command_environment () {
  parse_option --name \
      TEMPLATE_NAME \
      "Template name (must contain only alpha-numeric characters and underscores)" \
      "${__project_name}"

  export TEMPLATE_NAME="${TEMPLATE_NAME//[-.]/_}"

  if ! check_template && ! check_core; then
    parse_option --directory \
      TEMPLATE_PARENT_DIRECTORY \
      "Template project parent directory" \
      "$(pwd)"
  fi

  parse_flag --error \
    ERROR_EXISTS \
    "Return immediately with an error if template exists instead default behavior of updating"
}

function template_command () {
  if ! check_template && ! check_core; then
      local __template_dir="${TEMPLATE_PARENT_DIRECTORY}/${TEMPLATE_NAME}"
  else
      local __template_dir="${__templates_dir}/${TEMPLATE_NAME}"
  fi

  if [[ "$ERROR_EXISTS" ]] && [[ -d "${__template_dir}" ]]; then
      error "Template ${TEMPLATE_NAME} already exists at path: ${__template_dir}"
  fi

  "${__utilities_dir}/generate_template.py" "$TEMPLATE_NAME" "${__project_dir}" "${__template_dir}"
  run_hook template

  info "Template ${TEMPLATE_NAME} saved successfully"
}
