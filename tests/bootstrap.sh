#!/usr/bin/env bash
#
#=========================================================================================
# Initialization
#
set -e

# Initialize top level directories and load bootstrap functions
SCRIPT_PATH="${BASH_SOURCE[0]}" # bash
if [[ -z "$SCRIPT_PATH" ]]; then
  SCRIPT_PATH="${(%):-%N}" # zsh
fi

export __test_dir="$(cd "$(dirname "${SCRIPT_PATH}")" && pwd)"
export __project_dir="${__test_dir}/project"
export __reactor_dir="$(dirname "${__test_dir}")"
export __script_dir="${__reactor_dir}/scripts"

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

echo "Test directory: ${__test_dir}"
echo "Project directory: ${__project_dir}"
echo "Reactor directory: ${__reactor_dir}"
echo "Script directory: ${__script_dir}"
echo "Operating System: ${__os}"
echo "Computing Architecture: ${__architecture}"

# Verify intallation of required executables
which python3
which docker
which git
which curl
which openssl

# Install Python packages
if [ "${__os}" == "darwin" ]; then
  python3 -m pip install --upgrade pip setuptools wheel
  python3 -m pip install -r "${__reactor_dir}/requirements.txt"
else
  python3 -m pip install --upgrade pip setuptools wheel
  python3 -m pip install --no-build-isolation -r "${__reactor_dir}/requirements.txt"
fi
