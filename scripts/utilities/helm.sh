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


function update_helm_dependencies () {
  info "Updating chart Helm dependencies ..."
  for chart in $(config charts); do
    chart_dir="${__charts_dir}/${chart}/$(config charts.$chart.chart_dir "charts/${chart}")"

    info "Updating ${chart} Helm chart dependencies"
    "${__binary_dir}/helm" dependency update "$chart_dir" 1>>"$(logfile)" 2>&1
  done
}