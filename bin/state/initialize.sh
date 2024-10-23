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

export HOME_SHARES=(
  ".bashrc"
  ".bash_profile"
  ".profile"
  ".ssh"
  ".git"
)

if check_project; then
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
