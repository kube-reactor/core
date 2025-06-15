#!/usr/bin/env bash
#
# Usage:
#
#  source "${__bin_dir}/core/env.sh" $SOURCED
#
#  > Optional: ${__bin_dir}
#  > Optional: $SOURCED => [ 1, 0 ]
#  > App Arguments: ${__app_args}
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
# Need to preparse these because option parser is not run yet
#
# See: utilities/args.sh -> reactor_args

export arg_h=""
export arg_n=""
export arg_v=""
export arg_d=""
export arg_r=""

if [[ " ${__app_args[*]} " =~ " -h " ]] || [[ " ${__app_args[*]} " =~ " --help " ]]; then
    export arg_h="1"
fi
if [[ " ${__app_args[*]} " =~ " -n " ]] || [[ " ${__app_args[*]} " =~ " --no-color " ]]; then
    export arg_n="1"
fi
if [[ " ${__app_args[*]} " =~ " -v " ]] || [[ " ${__app_args[*]} " =~ " --verbose " ]]; then
    export arg_v="1"
fi
if [[ " ${__app_args[*]} " =~ " -d " ]] || [[ " ${__app_args[*]} " =~ " --debug " ]]; then
    export arg_d="1"
fi
if [[ " ${__app_args[*]} " =~ " -r " ]] || [[ " ${__app_args[*]} " =~ " --reload " ]]; then
    export arg_r="1"
fi

source "${__bin_dir}/core/loader.sh"
load_hook initialize

#
# Finalizing environment initialization
#
run_hook initialize
set_initialized
