#!/usr/bin/env bash
#-------------------------------------------------------------------------------
set -e

export __reactor_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export __bin_dir="${__reactor_dir}/bin"

#
# Collect and Check Dependencies
#
pwd

source "${__bin_dir}/core/loader"

#
# Collect and Check Dependencies
#
check_dependencies
setup_installer

#
# Run Installer
#
echo "3"
"${__reactor_dir}/requirements/install.sh"
echo "4"

#
# Cleanup Installation Files
#
clean_installer
