#
# MIN REQUIREMENTS:
#
#  * docker
#  * git
#

function install_debian () {
  sudo apt-get update -y 1>>"$(logfile)" 2>&1

  sed '/^\s*\#.*$/d' "${__reactor_dir}/requirements/packages_debian.txt" \
    | xargs -r sudo apt-get install -y --no-install-recommends 1>>"$(logfile)" 2>&1

  if ! which terraform 1>/dev/null 2>&1; then
    wget -O - https://apt.releases.hashicorp.com/gpg \
      | sudo gpg --yes --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 1>>"$(logfile)" 2>&1

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
      https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
      | sudo tee /etc/apt/sources.list.d/hashicorp.list 1>>"$(logfile)" 2>&1

    sudo apt-get update -y 1>>"$(logfile)" 2>&1
    sudo apt-get install -y terraform 1>>"$(logfile)" 2>&1
  fi
}

function install_mac () {
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
    exit 0
  fi
}
