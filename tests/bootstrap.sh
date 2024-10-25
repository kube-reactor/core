#!/usr/bin/env bash
#
#=========================================================================================
# Initialization
#
# Initialize top level directories and load bootstrap functions
SCRIPT_PATH="${BASH_SOURCE[0]}"

export __test_dir="$(cd "$(dirname "${SCRIPT_PATH}")" && pwd)"
export __project_dir="${__test_dir}/project"
export __reactor_dir="$(dirname "${__test_dir}")"
export __bin_dir="${__reactor_dir}/bin"

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
echo "Script directory: ${__bin_dir}"
echo "Operating System: ${__os}"
echo "Computing Architecture: ${__architecture}"

#=========================================================================================
# Boostrap process
#
set -e

# Verify intallation of required executables
which python3
which docker
which git
which curl
which openssl

# Install Python packages
python3 -m pip install --upgrade pip setuptools wheel

python3 -m pip install --no-build-isolation \
  --requirement "${__reactor_dir}/requirements.txt"
