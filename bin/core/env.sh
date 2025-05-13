#!/usr/bin/env bash
#
# Usage:
#
#  source "${__bin_dir}/core/env.sh" $SOURCED
#
#  > Optional: ${__bin_dir}
#  > Optional: $SOURCED => [ 1, 0 ]
#
#=========================================================================================
# Initialization
#
export SOURCED="$1"

if [ ! "${__bin_dir:-}" ]; then
    export __bin_dir="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")"
fi

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
