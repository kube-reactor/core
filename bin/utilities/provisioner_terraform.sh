#
#=========================================================================================
# Terraform Utilities
#

function provisioner_environment_terraform () {
  debug "Setting Terraform environment ..."
  export PROVISIONER_GATEWAY="${__argocd_apps_dir}/gateway"

  debug "PROVISIONER_GATEWAY: ${PROVISIONER_GATEWAY}"
}

function terraform_environment () {
  if [[ "${LOG_LEVEL:-0}" -ge 7 ]]; then
    export TF_LOG=DEBUG
  fi

  export TF_DATA_DIR="${__env_dir}/.terraform/${project_type}"
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
}


function run_provisioner_terraform () {
  local project_dir="$1"
  local project_type="$2"
  local local_state="${3:-}"
  shift; shift

  cd "$project_dir"

  terraform_environment

  if [ -f "${project_dir}/reactor_state.tf" ]; then
    rm -f "${project_dir}/reactor_state.tf"
  fi

  if [ "$local_state" ]; then
    terraform init 1>>"$(logfile)" 2>&1
  else
    ensure_remote_state

    if [[ "${__terraform_state_file:-}" ]] && [[ -f "${__terraform_state_file}" ]]; then
      cp "${__terraform_state_file:-}" "${project_dir}/reactor_state.tf"
    fi
    local state_options=($(get_remote_state "$project_type"))
    terraform init "${state_options[@]}" 1>>"$(logfile)" 2>&1
  fi
  terraform validate 1>>"$(logfile)" 2>&1

  if [ "${PROVISIONER_PLAN:-}" ]; then
    info "Testing Terraform project ..."
    terraform plan -input=false 1>>"$(logfile)" 2>&1
  else
    info "Deploying Terraform project ..."
    terraform apply -auto-approve -input=false 1>>"$(logfile)" 2>&1

    info "Capturing Terraform Output ..."
    terraform output -json 1>"${__env_dir}/${project_type}.output.json"
  fi
}


function run_provisioner_destroy_terraform () {
  local project_dir="$1"
  local project_type="$2"
  local local_state="${3:-}"
  shift; shift

  cd "$project_dir"

  terraform_environment

  if [ -f "${project_dir}/reactor_state.tf" ]; then
    rm -f "${project_dir}/reactor_state.tf"
  fi

  if [ "$local_state" ]; then
    terraform init 1>>"$(logfile)" 2>&1
  else
    ensure_remote_state

    if [[ "${__terraform_state_file:-}" ]] && [[ -f "${__terraform_state_file}" ]]; then
      cp "${__terraform_state_file:-}" "${project_dir}/reactor_state.tf"
    fi
    local state_options=($(get_remote_state "$project_type"))
    terraform init "${state_options[@]}" 1>>"$(logfile)" 2>&1
  fi
  terraform validate 1>>"$(logfile)" 2>&1

  info "Destroying Terraform project ..."
  terraform destroy -auto-approve -input=false 1>>"$(logfile)" 2>&1

  if [ -f "${__env_dir}/${project_type}.output.json" ]; then
    rm -f "${__env_dir}/${project_type}.output.json"
  fi
}

function run_provisioner_delete_terraform () {
  local project_dir="$1"
  local project_type="$2"
  local local_state="${3:-}"
  shift; shift

  cd "$project_dir"

  terraform_environment

  if [ -f "${project_dir}/reactor_state.tf" ]; then
    rm -f "${project_dir}/reactor_state.tf"
  fi

  if [ "$local_state" ]; then
    terraform init 1>>"$(logfile)" 2>&1
  else
    ensure_remote_state

    if [[ "${__terraform_state_file:-}" ]] && [[ -f "${__terraform_state_file}" ]]; then
      cp "${__terraform_state_file:-}" "${project_dir}/reactor_state.tf"
    fi
    local state_options=($(get_remote_state "$project_type"))
    terraform init "${state_options[@]}" 1>>"$(logfile)" 2>&1
  fi
  terraform validate 1>>"$(logfile)" 2>&1

  info "Deleting Terraform project ..."
  terraform state rm $(terraform state list) 1>>"$(logfile)" 2>&1

  if [ -f "${__env_dir}/${project_type}.output.json" ]; then
    rm -f "${__env_dir}/${project_type}.output.json"
  fi
}


function clean_provisioner_terraform () {
  provisioner_environment_terraform

  if [ -d "${__env_dir}/.terraform" ]; then
    info "Removing Terraform configuration ..."
    sudo rm -Rf "${__env_dir}/.terraform"
    rm -f "${PROVISIONER_GATEWAY}/.terraform.lock.hcl"
    rm -f "${PROVISIONER_GATEWAY}/terraform.tfvars"
    rm -f "${PROVISIONER_GATEWAY}/terraform.tfstate"*
  fi
}
