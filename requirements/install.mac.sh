#!/usr/bin/env bash
#-------------------------------------------------------------------------------
set -e
#
# MIN REQUIREMENTS: 
# 
#  * docker (Docker Descktop must be installed and running)
#  * git
#
check_binary brew 1>>"$(logfile)" 2>&1

if ! check_binary brew 1>>"$(logfile)" 2>&1; then 
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install openssl 1>>"$(logfile)" 2>&1
brew install grep 1>>"$(logfile)" 2>&1

if ! check_binary python3 1>>"$(logfile)" 2>&1; then 
  brew install python 1>>"$(logfile)" 2>&1
fi
if ! check_binary terraform 1>>"$(logfile)" 2>&1; then 
  brew tap hashicorp/tap 1>>"$(logfile)" 2>&1
  brew install hashicorp/tap/terraform 1>>"$(logfile)" 2>&1
fi

if [ "${__bash_version}" -lt "4" ]; then 
  echo "Reactor requires Bash version 4+"
  echo "Upgrading Bash version ..."
  brew install bash 1>>"$(logfile)" 2>&1
  echo ""
  echo "Your Bash version has been upgraded.  Please rerun this command"
  exit 1  
fi
