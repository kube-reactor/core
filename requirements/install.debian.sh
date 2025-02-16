#!/usr/bin/env bash
#-------------------------------------------------------------------------------
set -e
#
# MIN REQUIREMENTS: 
# 
#  * docker
#  * git
#

#
# Package Initialization
#
sudo apt-get update -y 1>>"$(logfile)" 2>&1

#
# Core Package Installation
#
sed '/^\s*\#.*$/d' "${__reactor_dir}/requirements/packages_debian.txt" \
  | xargs -r sudo apt-get install -y --no-install-recommends 1>>"$(logfile)" 2>&1

#
# Terraform Installation
#
if ! which terraform 1>/dev/null 2>&1; then
  wget -O - https://apt.releases.hashicorp.com/gpg \
    | sudo gpg --yes --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 1>>"$(logfile)" 2>&1

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list 1>>"$(logfile)" 2>&1

  sudo apt-get update -y 1>>"$(logfile)" 2>&1
  sudo apt-get install -y terraform 1>>"$(logfile)" 2>&1
fi
