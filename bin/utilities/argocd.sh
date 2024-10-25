#
#=========================================================================================
# ArgoCD Utilities
#

export ARGOCD_APPS_VERSION="${ARGOCD_APPS_VERSION:-main}"


function install_argocd () {
  download_binary argocd \
    "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-${__os}-${__architecture}" \
    "${__bin_dir}"

  info "Initializing ArgoCD application repository ..."
  download_git_repo \
    https://github.com/kube-reactor/argocd-apps.git \
    "${__argocd_apps_dir}" \
    "$ARGOCD_APPS_VERSION"
}


function login_argocd () {
  if kubernetes_status; then
    info "Logging into ArgoCD via CLI ..."
    debug "PRIMARY_DOMAIN: ${PRIMARY_DOMAIN}"
    debug "ARGOCD_ADMIN_PASSWORD: ${ARGOCD_ADMIN_PASSWORD}"

    "${__bin_dir}/argocd" login \
      "argocd.${PRIMARY_DOMAIN}" \
      --username admin --password \
      "$ARGOCD_ADMIN_PASSWORD" \
      --insecure --grpc-web 1>>"$(logfile)" 2>&1
  fi
}


function sync_argocd_charts () {
  update_helm_dependencies

  if kubernetes_status; then
    info "Syncing application charts into ArgoCD ..."
    login_argocd

    for chart in $(config charts); do
      app_name="$(config charts.$chart.app "$chart")"

      debug "app_name: ${app_name}"

      if "${__bin_dir}/argocd" app get "$app_name" >/dev/null 2>&1; then
        info "Syncing ${app_name} chart into ArgoCD ..."
        "${__bin_dir}/argocd" app set "$app_name" --grpc-web --sync-policy none 1>>"$(logfile)" 2>&1
        "${__bin_dir}/argocd" app sync "$app_name" --prune --grpc-web \
          --local "${__charts_dir}/${chart}/$(config charts.$chart.chart_dir "charts/${chart}")" 1>>"$(logfile)" 2>&1
      fi
    done
  fi
}
