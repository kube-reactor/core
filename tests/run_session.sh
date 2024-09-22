#!/usr/bin/env bash
#
#=========================================================================================
# Initialization
#
# Initialize top level directories and load bootstrap functions
SCRIPT_PATH="${BASH_SOURCE[0]}"

export __test_dir="$(cd "$(dirname "${SCRIPT_PATH}")" && pwd)"
export __reactor_dir="$(dirname "${__test_dir}")"
export __script_dir="${__reactor_dir}/scripts"
export __projects_dir="${__reactor_dir}/projects"
export __cookiecutter_dir="$(dirname "$(sudo find / -name cookiecutter | grep bin)")"

echo "Test directory: ${__test_dir}"
echo "Reactor directory: ${__reactor_dir}"
echo "Script directory: ${__script_dir}"
echo "Projects directory: ${__projects_dir}"
echo "Cookiecutter directory: ${__cookiecutter_dir}"

export PATH="${__script_dir}:${__cookiecutter_dir}:$PATH"

#=========================================================================================
# Project initialization
#
set -e

if [ -d "$PROJECT_TEMPLATE_DIRECTORY" ]; then
  __project_dir="$PROJECT_TEMPLATE_DIRECTORY"

  if [ -f "${__project_dir}/cookiecutter.json" ]; then
    reactor create --defaults \
      --project="${__project_dir}" \
      --directory="${__projects_dir}" \
      --name="test"

    __project_dir="${__projects_dir}/test"
  fi
else
  reactor create --defaults \
    --directory="${__projects_dir}" \
    --remote="${PROJECT_TEMPLATE_REMOTE:-https://github.com/zimagi/reactor-base-cluster.git}" \
    --reference="${PROJECT_TEMPLATE_REFERENCE:-main}" \
    --name="test"

  __project_dir="${__projects_dir}/test"
fi
export __project_dir

echo "Project directory: ${__project_dir}"
cd "${__project_dir}"

#=========================================================================================
# Development Session
#
#
# Starting Up
#
echo ""
echo "==========================================================================="
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "==========================================================================="
echo " Running Reactor startup"
echo ""
reactor up --build --no-cache --debug

if [[ ! -d "./cache" ]] \
  || [[ ! -d "./certs" ]] \
  || [[ ! -d "./docker" ]] \
  || [[ ! -d "./charts" ]] \
  || [[ ! -d "./.minikube" ]] \
  || [[ ! -f "./env/local/.kubeconfig" ]] \
  || [[ ! -f "./logs/tunnel.kpid" ]] \
  || [[ ! -d "./.terraform" ]] \
  || [[ ! -f "./terraform/argocd-apps/gateway/.terraform.lock.hcl" ]] \
  || [[ ! -f "./terraform/argocd-apps/gateway/terraform.tfstate" ]] \
  || [[ ! -f "./logs/hosts.txt" ]] \
  || ! cat /etc/hosts | grep test 1>/dev/null 2>/dev/null; then
  echo "Reactor up failed with missing files"
  exit 1
fi

echo ""
echo "> development environment"
source reactor
env

echo ""
echo "> docker ps -a"
docker ps -a
echo ""
echo "> docker images"
docker images

echo ""
echo "> minikube status"
minikube status
echo ""
echo "> kubectl get pods -A"
kubectl get pods -A
echo ""
echo "> kubectl get services -A"
kubectl get services -A
echo ""
echo "> kubectl get ingress -A"
kubectl get ingress -A

#
# Running Reactor Command Tests
#
for file in "${__test_dir}/commands"/*.sh; do
  echo ""
  echo "==========================================================================="
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "==========================================================================="
  echo " Running reactor command: ${file}"
  echo ""
  "$file"
done

#
# Running Project Command Tests
#
for file in "${__project_dir}/reactor/tests"/*.sh; do
  echo ""
  echo "==========================================================================="
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "==========================================================================="
  echo " Running reactor test: ${file}"
  echo ""
  "$file"
done

#
# Shutting Down
#
echo ""
echo "==========================================================================="
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "==========================================================================="
echo " Running Reactor shutdown"
echo ""
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
echo ""
echo "==========================================================================="
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "==========================================================================="
echo " Running Reactor cleanup"
echo ""
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
