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
load_hook initialize

#
# Finalizing environment initialization
#
set_initialized
run_hook initialize
