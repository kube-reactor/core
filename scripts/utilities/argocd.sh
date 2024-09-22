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
      "${ARGOCD_ADMIN_PASSWORD:-admin}" \
      --insecure --grpc-web
  fi
}

function sync_argocd_charts () {
  #generate_helm_template

  if minikube_status; then
    info "Syncing Zimagi chart into ArgoCD ..."
    login_argocd

    for chart in $(config charts); do
      if "${__binary_dir}/argocd" app get "$chart" 2>&1 >/dev/null; then
        info "Syncing ${chart} chart into ArgoCD ..."
        "${__binary_dir}/argocd" app set "$chart" --grpc-web --sync-policy none
        "${__binary_dir}/argocd" app sync "$chart" --prune --grpc-web \
          --local "${__charts_dir}/${chart}/$(config charts.$chart.chart_dir "charts/${chart}")" >"${__log_dir}/${chart}.sync.log" 2>&1

        if [ $? -ne 0 ]; then
          cat "${__log_dir}/${chart}.sync.log"
        fi
      fi
    done
  fi
}

function clean_argocd () {
  info "Cleaning ArgoCD files ..."
  for chart in $(config charts); do
    rm -f "${__log_dir}/${chart}.sync.log"
  done
}
