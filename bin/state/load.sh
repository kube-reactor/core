#
#=========================================================================================
# Script Loader
#

export LOG_LEVEL="${LOG_LEVEL:-6}" # 7 = debug -> 0 = emergency

if [ -f /REACTOR.txt ]; then
  export REACTOR_LOCAL=0
else
  export REACTOR_LOCAL=1
fi

# Set OS and system architecture variables.
case "$OSTYPE" in
  darwin*) __os="darwin" ;;
  linux*) __os="linux" ;;
  *) render "Unsupported OS: $OSTYPE"; exit 1 ;;
esac
export __os

case $(uname -m) in
    x86_64 | amd64) __architecture="amd64" ;;
    aarch64 | arm64) __architecture="arm64" ;;
    *) render "Unsupported CPU architecture: $(uname -m)"; exit 1 ;;
esac
export __architecture

export __environment="${REACTOR_ENV:-local}"
export __reactor_dir="$(dirname "${__script_dir}")"
export __reactor_version="$(cat -s "${__reactor_dir}/VERSION")"

export __state_dir="${__script_dir}/state"
source "${__state_dir}/bootstrap.sh"

export __binary_dir="${__script_dir}"
export __commands_dir="${__script_dir}/commands"
export __utilities_dir="${__script_dir}/utilities"
export __test_dir="${__reactor_dir}/tests"
export __projects_dir="${__reactor_dir}/projects"
export __project_file="$(project_file "$(pwd)")"

if [ "${__project_file}" ]; then
  export __project_dir="$(dirname "${__project_file}")"
  export __env_dir="${__project_dir}/env/${__environment}"
  export __init_file="${__env_dir}/.initialized"

  export __project_reactor_dir="${__project_dir}/reactor"

  export __app_dir="${__project_dir}/projects"
  export __certs_dir="${__project_dir}/certs"
  export __cache_dir="${__project_dir}/cache"

  export __docker_dir="${__project_dir}/docker"
  export __charts_dir="${__project_dir}/charts"
  export __extension_dir="${__project_dir}/extensions"

  export __reactor_invocation="$(printf %q "${__project_file}")$( (($#)) && printf ' %q' "$@" || true)"

  # Load environment configuration
  if [ -f "${__env_dir}/public.sh" ]; then
    source "${__env_dir}/public.sh"
  fi
  if [ -f "${__env_dir}/secret.sh" ]; then
    source "${__env_dir}/secret.sh"
  fi
fi


function load_utilities () {
  if [ $# -gt 0 ]; then
    for library in $@; do
      source "${__utilities_dir}/${library}.sh"
    done
  else
    for file in "${__utilities_dir}"/*.sh; do
      source "$file"
    done
  fi
}

function parse_cli () {
  local param_function="$1"
  shift

  load_utilities help
  reactor_args "$@"

  "$param_function"

  if [ "$arg_h" ]; then
    generic_usage "${HELP:-}"
  else
    render_overview
  fi
}
