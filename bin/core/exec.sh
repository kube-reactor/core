#!/usr/bin/env bash
#
# Usage:
#
#  "${__bin_dir}/core/exec.sh" [flags] <command> [args] [flags/options]
#
#=========================================================================================
# Initialization
#

# Error handling
set -o errexit

# Initialize top level directories and load bootstrap functions
SCRIPT_PATH="${BASH_SOURCE[0]}"

export __script_name="${__script_name:-$(basename "${SCRIPT_PATH//-/ }")}"
export __core_dir="$(cd "$(dirname "${SCRIPT_PATH}")" && pwd)"
export __bin_dir="$(dirname "${__core_dir}")"

source "${__core_dir}/env.sh" 0
reactor_args "$@"
run_local
