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
export __script_dir="${__test_dir}/scripts"

export PATH="${__script_dir}:$PATH"

echo "${__test_dir}"
echo "${__project_dir}"
echo "${__reactor_dir}"
echo "${__script_dir}"

docker images

exit 1
