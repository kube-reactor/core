#
# MIN REQUIREMENTS:
#
#  * docker
#  * git
#

function install_debian () {
  echo "-1-1"
  sudo apt-get update -y 1>>"$(logfile)" 2>&1

  echo "-1-2"

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
    git \
    openssh-client \
    sshpass \
    jq

  echo "-1-3"

  if ! which terraform 1>/dev/null 2>&1; then
    echo "-1-4"

    wget -O - https://apt.releases.hashicorp.com/gpg \
      | sudo gpg --yes --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 1>>"$(logfile)" 2>&1

    echo "-1-5"

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
      https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
      | sudo tee /etc/apt/sources.list.d/hashicorp.list 1>>"$(logfile)" 2>&1

    echo "-1-6"

    sudo apt-get update -y 1>>"$(logfile)" 2>&1

    echo "-1-7"

    sudo apt-get install -y terraform 1>>"$(logfile)" 2>&1

    echo "-1-8"
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
