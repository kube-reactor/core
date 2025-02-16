#!/usr/bin/env bash
#
# Usage:
#
#  source "${__bin_dir}/core/env.sh" $SOURCED
#
#  > Requires: ${__bin_dir}
#  > Optional: $SOURCED => [ 1, 0 ]
#
#=========================================================================================
# Initialization
#
export SOURCED="$1"

#
# Loading environment
#
source "${__bin_dir}/core/loader.sh"

#
# Loading utilities
#
load_hook initialize
load_utilities

#
# Initializing Docker environment
#
if kubernetes_status; then
  add_container_environment
fi

#
# Loading commands
#
load_commands

#
# Finalizing environment initialization
#
set_initialized
run_hook initialize
