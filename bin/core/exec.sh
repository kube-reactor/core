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

echo "" >"$(logfile)"
debug "====================================================================="
debug "Command: $@"
debug "====================================================================="
debug ""

debug "Environment Variables"
debug "======================================"
debug "$(render_environment)"
debug ""
#
#=========================================================================================
# Execution
#
if [[ "$arg_h" ]] || [[ ${#__app_args[@]} -eq 0 ]]; then
  if [[ ${#__app_args[@]} -gt 0 ]] && [[ "${__app_args[0]}" =~ ^[^-] ]]; then
    if function_exists "${__app_args[0]}_description"; then
      "${__app_args[0]}_description" >/dev/null 2>&1
      if [ -z "${PASSTHROUGH:-}" ]; then
        generate_command_help "${__app_args[0]}"
      fi
    fi
  else
    gateway_usage
  fi
fi

COMMAND="${__app_args[0]}"
COMMAND_ARGS=("${__app_args[@]:1}")

if [ "$COMMAND" == "help" ]; then
  if [[ ${#COMMAND_ARGS[@]} -eq 0 ]]; then
    gateway_usage
  else
    generate_command_help "${COMMAND_ARGS[0]}"
  fi
fi

pop_arg_command
run_command "$COMMAND" command "${COMMAND_ARGS[@]}"
