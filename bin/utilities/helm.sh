#
#=========================================================================================
# Helm Utilities
#

export DEFAULT_HELM_VERSION="3.15.4"


function helm_environment () {
  debug "Setting Helm environment ..."
  export HELM_VERSION="${HELM_VERSION:-$DEFAULT_HELM_VERSION}"

  debug "HELM_VERSION: ${HELM_VERSION}"
}


function install_helm () {
  helm_environment

  download_binary helm \
    "https://get.helm.sh/helm-v${HELM_VERSION}-${__os}-${__architecture}.tar.gz" \
    "${__bin_dir}" \
    "${__os}-${__architecture}"
}


function update_helm_dependencies () {
  info "Updating chart Helm dependencies ..."
  for chart in $(config charts); do
    chart_reference="$(config charts.$chart.project $chart)"
    chart_dir="${__repo_dir}/${chart_reference}/$(config charts.$chart.chart_dir "charts/${chart}")"

    if [ -d "$chart_dir" ]; then
      info "Updating ${chart} Helm chart dependencies"
      "${__bin_dir}/helm" dependency update "$chart_dir" 1>>"$(logfile)" 2>&1
    fi
  done
}
