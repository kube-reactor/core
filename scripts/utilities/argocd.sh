#
#=========================================================================================
# ArgoCD Utilities
#

function login_argocd () {
  if minikube_status; then
    info "Logging into ArgoCD via CLI ..."
    "${__binary_dir}/argocd" login \
      "argocd.${PRIMARY_DOMAIN}" \
      --username admin --password \
      "$ARGOCD_ADMIN_PASSWORD" \
      --insecure --grpc-web 1>>"$(logfile)" 2>&1
  fi
}

function sync_argocd_charts () {
  update_helm_dependencies

  if minikube_status; then
    info "Syncing application charts into ArgoCD ..."
    login_argocd

    for chart in $(config charts); do
      app_name="$(config charts.$chart.app "$chart")"

      if "${__binary_dir}/argocd" app get "$app_name" 2>&1 >/dev/null; then
        info "Syncing ${app_name} chart into ArgoCD ..."
        "${__binary_dir}/argocd" app set "$app_name" --grpc-web --sync-policy none 1>>"$(logfile)" 2>&1
        "${__binary_dir}/argocd" app sync "$app_name" --prune --grpc-web \
          --local "${__charts_dir}/${chart}/$(config charts.$chart.chart_dir "charts/${chart}")" 1>>"$(logfile)" 2>&1
      fi
    done
  fi
}