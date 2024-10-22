#
#=========================================================================================
# Project variables
#

# Set magic variables for directories.
export __terraform_dir="${__project_dir}/terraform"
export __argocd_apps_dir="${__terraform_dir}/argocd-apps"

# Default environment configuration
export DEFAULT_PROJECT_TEMPLATE_REMOTE="${DEFAULT_REACTOR_TEMPLATE_REMOTE:-https://github.com/kube-reactor/cluster-base.git}"
export DEFAULT_PROJECT_TEMPLATE_REFERENCE="${DEFAULT_REACTOR_TEMPLATE_REFERENCE:-main}"

export APP_NAME="$(config short_name)"
export APP_LABEL="$(config name)"

export PRIMARY_DOMAIN="$(echo "$APP_NAME" | tr '_' '-').local"

export HOME_SHARES=(
  ".bashrc"
  ".bash_profile"
  ".profile"
  ".ssh"
  ".git"
)

if [[ "${__project_dir}" ]] && [[ "${__command_name}" != "create" ]]; then
  # Set top level directory as working directory
  cd "${__project_dir}"

  # Directory creation
  mkdir -p "${__terraform_dir}"
  mkdir -p "${__cache_dir}"
  mkdir -p "${__certs_dir}"
  mkdir -p "${__docker_dir}"
  mkdir -p "${__charts_dir}"
fi

# Source initialization scripts
source_hook initialize
