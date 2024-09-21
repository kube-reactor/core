#
#=========================================================================================
# Project variables
#

# Set OS and system architecture variables.
case "$OSTYPE" in
  darwin*) __os="darwin" ;;
  linux*) __os="linux" ;;
  *) echo "Unsupported OS: $OSTYPE"; exit 1 ;;
esac
export __os

case $(uname -m) in
    x86_64 | amd64) __architecture="amd64" ;;
    aarch64 | arm64) __architecture="arm64" ;;
    *) echo "Unsupported CPU architecture: $(uname -m)"; exit 1 ;;
esac
export __architecture

# Set magic variables for directories.
export __project_reactor_dir="${__project_dir}/reactor"
export __project_utilities_dir="${__project_reactor_dir}/utilities"
export __project_commands_dir="${__project_reactor_dir}/commands"

export __app_dir="${__project_dir}/projects"

export __log_dir="${__project_dir}/logs"

export __binary_dir="${__script_dir}"
export __certs_dir="${__project_dir}/certs"
export __extension_dir="${__project_dir}/extensions"
export __docker_dir="${__project_dir}/docker"
export __charts_dir="${__project_dir}/charts"
export __terraform_dir="${__project_dir}/terraform"
export __cache_dir="${__project_dir}/cache"

export __argocd_apps_dir="${__terraform_dir}/argocd-apps"

# shellcheck disable=SC2034,SC2015
export __reactor_invocation="$(printf %q "${__project_file}")$( (($#)) && printf ' %q' "$@" || true)"
export __reactor_core_flags="
    --verbose             Enable verbose mode, print script as it is executed
    --debug               Enables debug mode
    --no-color            Disable color output
    -h --help             Display help message"

# Default environment configuration
export DEFAULT_PROJECT_TEMPLATE_REMOTE="${DEFAULT_REACTOR_TEMPLATE_REMOTE:-https://github.com/zimagi/reactor-base-cluster.git}"
export DEFAULT_PROJECT_TEMPLATE_REFERENCE="${DEFAULT_REACTOR_TEMPLATE_REFERENCE:-main}"

export LOG_LEVEL="${LOG_LEVEL:-6}" # 7 = debug -> 0 = emergency
export NO_COLOR="${NO_COLOR:-}"    # true = disable color. otherwise autodetected

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

if [ "${__command_name}" != "create" ]; then
  # Set top level directory as working directory
  cd "${__project_dir}"

  # Directory creation
  mkdir -p "${__terraform_dir}"
  mkdir -p "${__cache_dir}"
  mkdir -p "${__log_dir}"
  mkdir -p "${__certs_dir}"
  mkdir -p "${__docker_dir}"
  mkdir -p "${__charts_dir}"
fi

# Include dependency initialization if it exists
for project in $(config docker); do
  project_dir="${__docker_dir}/${project}"
  initialize_script="${project_dir}/reactor/initialize.sh"
  if [ -f "$initialize_script" ]; then
    source "$initialize_script" "$project"
  fi
  initialize_script="${__project_reactor_dir}/docker/${project}_initialize.sh"
  if [ -f "$initialize_script" ]; then
    source "$initialize_script" "$project"
  fi
done
for chart in $(config charts); do
  chart_dir="${__charts_dir}/${chart}"
  initialize_script="${chart_dir}/reactor/initialize.sh"
  if [ -f "$initialize_script" ]; then
    source "$initialize_script" "$chart"
  fi
  initialize_script="${__project_reactor_dir}/charts/${chart}_initialize.sh"
  if [ -f "$initialize_script" ]; then
    source "$initialize_script" "$project"
  fi
done
for extension in $(config extensions); do
  extension_dir="${__extension_dir}/${extension}"
  initialize_script="${extension_dir}/reactor/initialize.sh"
  if [ -f "$initialize_script" ]; then
    source "$initialize_script" "$extension"
  fi
done

# Include project initialization if it exists
if [ -f "${__project_reactor_dir}/initialize.sh" ]; then
  source "${__project_reactor_dir}/initialize.sh"
fi
