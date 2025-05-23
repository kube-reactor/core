#
# MIN REQUIREMENTS:
#
#  * docker
#  * git
#

function install_debian () {
  sudo apt-get update -y 1>>"$(logfile)" 2>&1
  sudo apt-get install -y --no-install-recommends \
    curl \
    wget \
    lsb-release \
    netbase \
    gnupg2 \
    ca-certificates \
    openssl \
    vim \
    gcc \
    g++ \
    make \
    cmake \
    libssl-dev \
    unzip \
    python3-dev \
    python3-pip \
    python3-venv \
    git \
    sshpass \
    jq 1>>"$(logfile)" 2>&1

  if ! which terraform 1>/dev/null 2>&1; then
    wget -O - https://apt.releases.hashicorp.com/gpg \
      | sudo gpg --yes --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 1>>"$(logfile)" 2>&1

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
      https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
      | sudo tee /etc/apt/sources.list.d/hashicorp.list 1>>"$(logfile)" 2>&1

    sudo apt-get update -y 1>>"$(logfile)" 2>&1
    sudo apt-get install -y terraform 1>>"$(logfile)" 2>&1
  fi

  if ! which gh 1>/dev/null 2>&1; then
    wget -O - https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo gpg --yes --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg 1>>"$(logfile)" 2>&1

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
      https://cli.github.com/packages stable main" \
      | sudo tee /etc/apt/sources.list.d/github-cli.list 1>>"$(logfile)" 2>&1

    sudo apt-get update -y 1>>"$(logfile)" 2>&1
    sudo apt-get install -y gh 1>>"$(logfile)" 2>&1
  fi
}

function install_mac () {
  if ! which brew 1>/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew update 1>>"$(logfile)" 2>&1

  if [ "${__bash_version}" -lt "4" ]; then
    echo "Reactor requires Bash version 4+"
    echo "Upgrading Bash version ..."
    brew install bash 1>>"$(logfile)" 2>&1
    echo ""
    echo "Your Bash version has been upgraded.  Please rerun this command"
    exit 0
  fi

  brew install openssl 1>>"$(logfile)" 2>&1
  brew install grep 1>>"$(logfile)" 2>&1

  if ! which python3 1>/dev/null 2>&1; then
    brew install python 1>>"$(logfile)" 2>&1
  fi
  if ! which terraform 1>/dev/null 2>&1; then
    brew tap hashicorp/tap 1>>"$(logfile)" 2>&1
    brew install hashicorp/tap/terraform 1>>"$(logfile)" 2>&1
  fi
  if ! which gh 1>/dev/null 2>&1; then
    brew install gh 1>>"$(logfile)" 2>&1
  fi
}
