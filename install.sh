#!/usr/bin/env bash
#-------------------------------------------------------------------------------
set -e

export __reactor_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export __bin_dir="${__reactor_dir}/bin"

#
# Collect and Check Dependencies
#
source "${__bin_dir}/core/loader.sh"

#
# Collect and Check Dependencies
#
check_dependencies

if check_project; then
  setup_installer
fi

#
# Run Installer
#
"${__reactor_dir}/requirements/install.sh"

#
# Cleanup Installation Files
#
if check_project; then
  clean_installer
fi
