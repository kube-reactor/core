#
#=========================================================================================
# Project variables
#

if check_project; then
  # Set top level directory as working directory
  cd "${__project_dir}"

  # Directory creation
  mkdir -p "${__cache_dir}"
  mkdir -p "${__certs_dir}"
  mkdir -p "${__repo_dir}"
fi
