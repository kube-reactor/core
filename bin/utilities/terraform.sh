#
#=========================================================================================
# Terraform Utilities
#

function terraform_environment () {
  debug "Setting Terraform environment ..."
  export TERRAFORM_GATEWAY="${__argocd_apps_dir}/gateway"

  debug "TERRAFORM_GATEWAY: ${TERRAFORM_GATEWAY}"
}


function run_terraform () {
  terraform_environment
  cert_environment
  kubernetes_environment
  helm_environment

  install_argocd

  local project_dir="$1"
  local project_type="$2"
  shift; shift

  cd "$project_dir"

  if [[ "${LOG_LEVEL:-0}" -ge 7 ]]; then
    export TF_LOG=DEBUG
  fi

  export TF_DATA_DIR="${__project_dir}/.terraform/${project_type}"
  export TF_VAR_kube_config="$KUBECONFIG"
  export TF_VAR_domain="$PRIMARY_DOMAIN"
  export TF_VAR_environment="${__environment}"
  export TF_VAR_variables="$(env_json)"

  debug "Terraform project environment variables"
  debug ""
  debug "TF_DATA_DIR: ${TF_DATA_DIR}"
  debug "VAR: kube_config: ${TF_VAR_kube_config}"
  debug "VAR: domain: ${TF_VAR_domain}"
  debug "VAR: environment: ${TF_VAR_environment}"
  debug ""
  debug "Variables:"
  debug "-------------------------------------"
  debug "$TF_VAR_variables"
  debug ""

  terraform init "${@}" 1>>"$(logfile)" 2>&1
  terraform validate 1>>"$(logfile)" 2>&1

  if [ "${TERRAFORM_DESTROY:-}" ]; then
    info "Deploying Terraform project ..."
    terraform destroy -auto-approve -input=false 1>>"$(logfile)" 2>&1

  elif [ "${TERRAFORM_PLAN:-}" ]; then
    info "Testing Terraform project ..."
    terraform plan -input=false 1>>"$(logfile)" 2>&1

  else
    info "Deploying Terraform project ..."
    terraform apply -auto-approve -input=false 1>>"$(logfile)" 2>&1

    info "Capturing Terraform Output ..."
    terraform output -json 1>"${__env_dir}/${project_type}.json"
  fi
}


function clean_terraform () {
  if [ -d "${__project_dir}/.terraform" ]; then
    terraform_environment

    info "Removing Terraform configuration ..."
    sudo rm -Rf "${__project_dir}/.terraform"
    rm -f "${TERRAFORM_GATEWAY}/.terraform.lock.hcl"
    rm -f "${TERRAFORM_GATEWAY}/terraform.tfvars"
    rm -f "${TERRAFORM_GATEWAY}/terraform.tfstate"*
  fi

  run_hook clean_terraform
}
