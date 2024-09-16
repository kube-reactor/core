#
#=========================================================================================
# ArgoCD Utilities
#

function login_argocd () {
  if minikube_status; then
    info "Logging into ArgoCD via CLI ..."
    argocd login \
      "argocd.${PRIMARY_DOMAIN}" \
      --username admin --password \
      "${ARGOCD_ADMIN_PASSWORD:-admin}" \
      --insecure --grpc-web
  fi
}

# function sync_argocd_chart () {
#   local chart_index_file="${__argocd_charts_dir}/index.txt"

#   generate_helm_template

#   if minikube_status; then
#     info "Syncing Zimagi chart into ArgoCD ..."

#     login_argocd

#     if argocd app get zimagi 2>&1 >/dev/null; then
#       argocd app set zimagi --grpc-web --sync-policy none
#       argocd app sync zimagi --prune --grpc-web \
#         --local "${__charts_dir}/charts/zimagi" >"${__data_dir}/zimagi.sync.log" 2>&1

#       if [ $? -ne 0 ]; then
#         cat "${__data_dir}/zimagi.sync.log"
#       fi
#     fi

#     if [ -f "${chart_index_file}" ]; then
#       while read -r LINE; do
#         spec=(${LINE//=/})
#         app_name="${spec[0]}"
#         chart_path="${__argocd_charts_dir}/${spec[1]}"

#         if argocd app get "${app_name}" 2>&1 >/dev/null; then
#           argocd app set "${app_name}" --grpc-web --sync-policy none
#           argocd app sync "${app_name}" --prune --grpc-web \
#             --local "$chart_path" >"${__data_dir}/${app_name}.sync.log" 2>&1

#           if [ $? -ne 0 ]; then
#             cat "${__data_dir}/${app_name}.sync.log"
#           fi
#         fi
#       done < "${chart_index_file}"
#     fi

#     #for path in "${__argocd_charts_dir}/"*/; do
#     #  if [ -d "$path" ]; then
#     #    echo $path
#     #  fi
#     #done
#   fi
# }

# function clean_argocd () {
#   info "Cleaning ArgoCD files ..."
#   rm -f "${__data_dir}/zimagi.sync.log"
# }
