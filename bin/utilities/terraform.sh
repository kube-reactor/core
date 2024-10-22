#
#=========================================================================================
# Terraform Utilities
#

export DEFAULT_TERRAFORM_VERSION="1.9.5"


function terraform_environment () {
  debug "Setting Terraform environment ..."
  export TERRAFORM_VERSION="${TERRAFORM_VERSION:-$DEFAULT_TERRAFORM_VERSION}"
  export TERRAFORM_GATEWAY="${__argocd_apps_dir}/gateway"

  debug "TERRAFORM_VERSION: ${TERRAFORM_VERSION}"
  debug "TERRAFORM_GATEWAY: ${TERRAFORM_GATEWAY}"
}


function provision_terraform () {
  if kubernetes_status; then
    cert_environment
    terraform_environment
    helm_environment

    export TF_VAR_variables="$(env_json)"

    debug "Terraform project environment variables"
    debug "${TF_VAR_variables}"

    TERRAFORM_ARGS=(
      "--rm"
      "--network" "host"
      "--volume" "${__project_dir}:${__project_dir}"  # Kubernetes host path -> Terraform container path
      "--workdir" "${TERRAFORM_GATEWAY}"
      "--env" "TF_DATA_DIR=${__project_dir}/.terraform"
      "--env" "TF_VAR_project_path=${__project_dir}"
      "--env" "TF_VAR_kube_config=${__env_dir}/.kubeconfig"
      "--env" "TF_VAR_domain=${PRIMARY_DOMAIN}"
      "--env" "TF_VAR_environment=${__environment}"
      "--env" "TF_VAR_argocd_admin_password=$("${__binary_dir}/argocd" account bcrypt --password "${ARGOCD_ADMIN_PASSWORD:-admin}")"
      "--env" "TF_VAR_variables"
    )
    if [ ! -z "${ARGOCD_PROJECT_SEQUENCE}" ]; then
      export TF_VAR_argocd_project_sequence="${ARGOCD_PROJECT_SEQUENCE}"
      TERRAFORM_ARGS=("${TERRAFORM_ARGS[@]}" "--env" "TF_VAR_argocd_project_sequence")
    fi
    if [[ "${LOG_LEVEL:-0}" -ge 7 ]]; then
      TERRAFORM_ARGS=("${TERRAFORM_ARGS[@]}" "--env" "TF_LOG=DEBUG")
    fi

    TERRAFORM_ARGS=(
      "${TERRAFORM_ARGS[@]}"
      "hashicorp/terraform:${TERRAFORM_VERSION}"
    )
    debug "Terraform Arguments: ${TERRAFORM_ARGS[@]}"

    info "Initializing Terraform project ..."
    docker run "${TERRAFORM_ARGS[@]}" init 1>>"$(logfile)" 2>&1

    info "Validating Terraform project ..."
    docker run "${TERRAFORM_ARGS[@]}" validate 1>>"$(logfile)" 2>&1

    info "Deploying Kubernetes cluster ..."
    docker run "${TERRAFORM_ARGS[@]}" apply -auto-approve -input=false 1>>"$(logfile)" 2>&1
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
}
