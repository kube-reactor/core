#!/bin/bash
#-------------------------------------------------------------------------------
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REACTOR_DIR="$(cd "$(dirname "$SCRIPT_DIR")" && pwd)"

#
# Package Initialization
#
sudo apt-get update -y

#
# Core Package Installation
#
sed '/^\s*\#.*$/d' "${REACTOR_DIR}/requirements/packages.txt" \
  | xargs -r sudo apt-get install -y --no-install-recommends

#
# Terraform Installation
#
if ! which terraform 1>/dev/null 2>&1; then
  wget -O - https://apt.releases.hashicorp.com/gpg \
    | sudo gpg --yes --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list

  sudo apt-get update -y
  sudo apt-get install -y terraform
fi

#
# Reactor Python Requirements Installation
#
pip3 install --no-cache-dir -r "${REACTOR_DIR}/requirements/requirements.txt"

#
# Reactor Project Installer Installation
#
if compgen -G "${REACTOR_DIR}/installer/"*.txt >/dev/null; then
  for requirements in "${REACTOR_DIR}/installer/"*.txt; do
    pip3 install --no-cache-dir -r "$requirements"
  done
fi
if compgen -G "${REACTOR_DIR}/installer/"*.sh >/dev/null; then
  for script in "${REACTOR_DIR}/installer/"*.sh; do
    "$script"
  done
fi
