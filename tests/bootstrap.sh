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

echo "Test directory: ${__test_dir}"
echo "Project directory: ${__project_dir}"
echo "Reactor directory: ${__reactor_dir}"
echo "Script directory: ${__script_dir}"

# Verify intallation of required executables
which python3
which docker
which git
which curl
which openssl

# Install Python packages
sudo python3 -m pip install -r "${__reactor_dir}/requirements.txt"
