#!/usr/bin/env bash
#
# Usage:
#
#  source "${__bin_dir}/core/loader.sh"
#
#  > Requires: ${__bin_dir}
#
#=========================================================================================
# Initialization
#
# Shell options
set -e
set -o errtrace
set -o nounset

shopt -s expand_aliases

#
# Reactor Core Initialization
#
function init_core () {
  export __environment="${REACTOR_ENVIRONMENT:-local}"

  export __reactor_dir="$(dirname "$1")"
  export __bin_dir="${__reactor_dir}/bin"

  export __core_dir="${__bin_dir}/core"
  export __core_lib_dir="${__core_dir}/lib"

  export __commands_dir="${__bin_dir}/commands"
  export __utilities_dir="${__bin_dir}/utilities"
  export __test_dir="${__reactor_dir}/tests"
  export __test_lib_dir="${__test_dir}/lib"
  export __templates_dir="${__reactor_dir}/templates"
  export __projects_dir="${__reactor_dir}/projects"

  export __reactor_version="$(cat -s "${__reactor_dir}/VERSION")"

  source "${__core_lib_dir}/bootstrap.sh"
  source "${__core_lib_dir}/aliases.sh"
}

#
# >>> Startup
#
export INITIALIZED=""
export LOG_LEVEL="${LOG_LEVEL:-6}" # 7 = debug -> 0 = emergency

# Set OS and system architecture variables.
case "$OSTYPE" in
  darwin*)
    __os="darwin"
    __os_type="mac"
    __os_dist="mac"
    ;;
  linux*)
    __os="linux"

    source /etc/os-release
    __os_dist="$ID"

    case $ID in
      debian) __os_type="debian" ;;
      ubuntu) __os_type="debian" ;;
      linuxmint) __os_type="debian" ;;
      arch) __os_type="arch" ;;
      centos) __os_type="redhat" ;;
      fedora) __os_type="redhat" ;;
      rhel) __os_type="redhat" ;;
      amzn) __os_type="redhat" ;;
      *) render "Unsupported OS: $OSTYPE $ID"; exit 1 ;;
    esac
    ;;
  *) render "Unsupported OS: $OSTYPE"; exit 1 ;;
esac
export __os
export __os_type
export __os_dist

case $(uname -m) in
    x86_64 | amd64) __architecture="amd64" ;;
    aarch64 | arm64) __architecture="arm64" ;;
    *) render "Unsupported CPU architecture: $(uname -m)"; exit 1 ;;
esac
export __architecture

export __bash_version="$(echo "$BASH_VERSION" | sed -E 's/^([0-9]+).*/\1/')"

export __user_id="$(id -u)"
export __user_name="$(id -nu)"
export __group_id="$(id -g)"
export __group_name="$(id -ng)"

if [ "${__os}" == "darwin" ]; then
  gid="$(awk -F: -v group=docker '$1==group{print $3}' /etc/group)"
  if [ ! "$gid" ]; then
    gid="$(awk -F: -v group=daemon '$1==group{print $3}' /etc/group)"
  fi
  __docker_group_id="$gid"
else
  __docker_group_id="$(cut -d: -f3 < <(getent group docker))"
fi
export __docker_group_id

if [ "${HOME:-}" ]; then
  export __home_dir="$HOME"
else
  if [ "${__os}" == "darwin" ]; then
    export __home_dir="/Users/${__user_name}"
  else
    export __home_dir="/home/${__user_name}"
  fi
  export HOME="${__home_dir}"
fi

if [ -z "${HOME_SHARES:-}" ]; then
  export HOME_SHARES=(
    ".ssh"
    ".git"
  )
fi

export DEFAULT_PROJECT_URL="${DEFAULT_REACTOR_URL:-https://github.com/kube-reactor/cluster-base-aws.git}"
export DEFAULT_PROJECT_REMOTE="${DEFAULT_REACTOR_REMOTE:-origin}"
export DEFAULT_PROJECT_REFERENCE="${DEFAULT_REACTOR_REFERENCE:-main}"

init_core "${__bin_dir}"

export __core_manifest="$(core_manifest "$(pwd)")"
export __template_manifest="$(template_manifest "$(pwd)")"
export __project_manifest="$(project_manifest "$(pwd)")"
export __project_dir="$(dirname "${__project_manifest}")"
export __project_name="${REACTOR_PROJECT_NAME:-$(date +%Y%m%d_%H%M%S)}"

#
# Core Development Mode
#
if [ "${__core_manifest}" ]; then
  init_core "${__core_manifest}"
  if [ -d "${__projects_dir}/${__project_name}" ]; then
    export __project_manifest="$(project_manifest "${__projects_dir}/${__project_name}")"
  fi
fi

#
# Load Runtime dependencies
#
source "${__utilities_dir}/env.sh"
source "${__utilities_dir}/hooks.sh"
source "${__utilities_dir}/disk.sh"
source "${__utilities_dir}/cli.sh"
source "${__core_lib_dir}/runtime.sh"
source "${__core_lib_dir}/install.sh"

#
# Checking application requirements
#
if ! is_setup_complete; then
  echo "" >"$(logfile)"
  check_dependencies
  echo "-1"

  if function_exists "install_${__os_type}"; then
    echo "-2"
    "install_${__os_type}"
  fi
  echo "-3"

  if [[ "${__os_type}" != "${__os_dist}" ]] && function_exists "install_${__os_dist}"; then
    echo "-4"
    "install_${__os_dist}"
  fi
  echo "-5"
  python3 -m venv "${HOME}/.reactor/python" 1>>"$(logfile)" 2>&1
fi
echo "-6"

export PATH="${__bin_dir}:${HOME}/.reactor/python/bin:${PATH}"
source "${HOME}/.reactor/python/bin/activate"

echo "-7"

if ! is_setup_complete; then
  echo "-8"
  python3 -m pip install -U pip setuptools wheel --ignore-installed 1>>"$(logfile)" 2>&1
  echo "-9"
  pip3 install --no-cache-dir -r "${__reactor_dir}/requirements/requirements.txt"
fi
echo "-10"

#
# Initializing template development mode
#
if [ "${__template_manifest}" ]; then
  init_template "${__template_manifest}"
  if [ -d "${__template_dir}/${__project_name}" ]; then
    export __project_manifest="$(project_manifest "${__template_dir}/${__project_name}")"
  fi
fi
echo "-11"

#
# Initializing project development mode
#
if [ "${__project_manifest}" ]; then
  init_project "${__project_manifest}"
fi
echo "-12"

#
# Initialize the command and utility file indexes
#
init_loader
echo "-13"

#
# Bash options (require Bash v4+)
#
shopt -s globstar
