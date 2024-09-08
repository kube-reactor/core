#
#=========================================================================================
# Terraform Utilities
#

export DEFAULT_TERRAFORM_VERSION="1.9.5"

function terraform_environment () {
  debug "Setting Terraform environment ..."
  export TERRAFORM_VERSION="${TERRAFORM_VERSION:-$DEFAULT_TERRAFORM_VERSION}"

  debug "export TERRAFORM_VERSION: ${TERRAFORM_VERSION}"
}


function provision_terraform () {
  if minikube_status; then
    cert_environment
    terraform_environment

    export TF_VAR_ssl_certificate="${APP_CERT}"
    export TF_VAR_ssl_private_key="${APP_KEY}"

    TERRAFORM_ARGS=(
      "--rm"
      "--network" "host"
      "--volume" "/project:/project"  # Minikube host path -> Terraform container path
      "--workdir" "/project/terraform/applications"
      "--env" "TF_LOG=DEBUG"
      "--env" "TF_DATA_DIR=/project/.terraform"
      "--env" "TF_VAR_project_path=/project"
      "--env" "TF_VAR_kube_config=/project/env/${__environment}/.kubeconfig"
      "--env" "TF_VAR_domain=$(echo "$APP_NAME" | tr '_' '-').local"
      "--env" "TF_VAR_environment=${__environment}"
      "--env" "TF_VAR_gateway_node_port=${CLUSTER_GATEWAY_PORT:-32210}"
      "--env" "TF_VAR_argocd_admin_password=$("${__binary_dir}/argocd" account bcrypt --password "${ARGOCD_ADMIN_PASSWORD:-admin}")"
    )
    while IFS= read -r variable; do
      TERRAFORM_ARGS=("${TERRAFORM_ARGS[@]}" "--env" "$variable")
    done <<< "$(env | grep -o "TF_VAR_[_A-Za-z0-9]*")"

    TERRAFORM_ARGS=(
      "${TERRAFORM_ARGS[@]}"
      "hashicorp/terraform:${TERRAFORM_VERSION}"
    )
    debug "Terraform Arguments: ${TERRAFORM_ARGS[@]}"

    info "Initializing Terraform project ..."
    docker run "${TERRAFORM_ARGS[@]}" init

    info "Validating Terraform project ..."
    docker run "${TERRAFORM_ARGS[@]}" validate

    info "Deploying Zimagi cluster ..."
    docker run "${TERRAFORM_ARGS[@]}" apply -auto-approve -input=false
  fi
}

function clean_terraform () {
  if [ -d "${__project_dir}/.terraform" ]; then
    info "Removing Terraform configuration ..."
    sudo rm -Rf "${__project_dir}/.terraform"
    rm -f "${__terraform_dir}/applications/.terraform.lock.hcl"
    rm -f "${__terraform_dir}/applications/terraform.tfvars"
    rm -f "${__terraform_dir}/applications/terraform.tfstate"*
  fi
}
