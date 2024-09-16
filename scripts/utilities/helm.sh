#
#=========================================================================================
# Helm Utilities
#

export DEFAULT_HELM_VERSION="3.15.4"

function helm_environment () {
  debug "Setting Helm environment ..."
  export HELM_VERSION="${HELM_VERSION:-$DEFAULT_HELM_VERSION}"
  export HELM_REPOSITORY_CACHE="${__cache_dir}/helm"

  debug "HELM_VERSION: ${HELM_VERSION}"
  debug "HELM_REPOSITORY_CACHE: ${HELM_REPOSITORY_CACHE}"
}


# function update_helm_dependencies () {
#   info "Updating chart Helm dependencies ..."
#   helm dependency update \
#     "${__charts_dir}/charts/zimagi"
# }

# function generate_helm_template () {
#   update_helm_dependencies

#   TEMPLATE_ARGS=(
#     "template"
#     "zimagi"
#     "${__charts_dir}/charts/zimagi"
#     "-f" "${__cluster_dir}/projects/platform/zimagi/values.yaml"
#     "-n" "zimagi"
#   )

#   info "Generating Zimagi Helm template ..."
#   helm "${TEMPLATE_ARGS[@]}" >"${__zimagi_data_dir}/zimagi.helm.template.yml" 2>&1

#   if [ $? -ne 0 ]; then
#     helm "${TEMPLATE_ARGS[@]}" --debug
#   fi
# }

# function clean_helm () {
#   info "Cleaning Helm files ..."
#   rm -f "${__env_dir}/zimagi.helm.template.yml"
# }
