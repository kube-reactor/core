#
#=========================================================================================
# Initialization
#
set -e

# Initialize top level directories and load bootstrap functions
SCRIPT_PATH="${BASH_SOURCE[0]}" # bash
if [[ -z "$SCRIPT_PATH" ]]; then
  SCRIPT_PATH="${(%):-%N}" # zsh
fi

export __test_dir="$(cd "$(dirname "${SCRIPT_PATH}")" && pwd)"
export __project_dir="${__test_dir}/project"
export __reactor_dir="$(dirname "${__test_dir}")"
export __script_dir="${__reactor_dir}/scripts"

echo "Test directory: ${__test_dir}"
echo "Project directory: ${__project_dir}"
echo "Reactor directory: ${__reactor_dir}"
echo "Script directory: ${__script_dir}"

export PATH="${__script_dir}:$PATH"
cd "${__project_dir}"

#=========================================================================================
# Development Session
#

#
# Starting Up
#
reactor up --build --debug

if [[ ! -d "./cache" ]] \
  || [[ ! -d "./certs" ]] \
  || [[ ! -d "./docker" ]] \
  || ! git --work-tree=./docker/zimagi status 1>/dev/null 2>&1 \
  || [[ ! -d "./charts" ]] \
  || ! git --work-tree=./charts/zimagi status 1>/dev/null 2>&1 \
  || [[ ! -d "./.minikube" ]] \
  || [[ ! -f "./env/local/.kubeconfig" ]] \
  || [[ ! -f "./logs/tunnel.kpid" ]] \
  || [[ ! -f "./logs/dashboard.kpid" ]] \
  || [[ ! -d "./.terraform" ]] \
  || [[ ! -f "./terraform/argocd-apps/gateway/.terraform.lock.hcl" ]] \
  || [[ ! -f "./terraform/argocd-apps/gateway/terraform.tfstate" ]] \
  || [[ ! -f "./logs/hosts.txt" ]] \
  || ! cat /etc/hosts | grep test 1>/dev/null 2>/dev/null; then
  echo "Reactor up failed with missing files"
  exit 1
fi

#
# Running Command Tests
#
for file in "${__test_dir}/commands"/*.sh; do
  echo "$file"
done

#
# Shutting Down
#
reactor down --debug

if [[ -f "./env/local/.kubeconfig" ]] \
  || [[ -f "./logs/tunnel.kpid" ]] \
  || [[ -f "./logs/dashboard.kpid" ]] \
  || [[ -f "./logs/hosts.txt" ]] \
  || cat /etc/hosts | grep test; then
  echo "Reactor down failed with remaining files"
  exit 1
fi

#
# Cleaning Up
#
reactor destroy --force --debug

if [[ -d "./.minikube" ]] \
  || [[ -d "./.terraform" ]] \
  || [[ -f "./terraform/argocd-apps/gateway/.terraform.lock.hcl" ]] \
  || [[ -f "./terraform/argocd-apps/gateway/terraform.tfstate" ]]; then
  echo "Reactor destroy failed with remaining files"
  exit 1
fi

reactor clean --force --debug

if [[ -d "./cache" ]] \
  || [[ -d "./certs" ]]; then
  echo "Reactor clean failed with remaining files"
  exit 1
fi
