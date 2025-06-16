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
    debug "ARGOCD_DOMAIN: ${ARGOCD_DOMAIN}"
    debug "ARGOCD_ADMIN_PASSWORD: ${ARGOCD_ADMIN_PASSWORD}"

    "${__bin_dir}/argocd" login \
      "$ARGOCD_DOMAIN" \
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
      extension="$(config charts.$chart.extension $chart)"
      chart_dir="${__repo_dir}/$(config extensions.$extension.directory $extension)/$(config charts.$chart.directory "charts/${chart}")"

      if [ -d "$chart_dir" ]; then
        app_name="$(config charts.$chart.application "$chart")"

        debug "app_name: ${app_name}"

        if "${__bin_dir}/argocd" app get "$app_name" --insecure >/dev/null 2>&1; then
          info "Syncing ${app_name} chart into ArgoCD ..."
          "${__bin_dir}/argocd" app set "$app_name" --insecure --grpc-web --sync-policy none 1>>"$(logfile)" 2>&1
          "${__bin_dir}/argocd" app sync "$app_name" --prune --insecure --grpc-web \
            --local "$chart_dir" 1>>"$(logfile)" 2>&1
        fi
      fi
    done
  fi
}
