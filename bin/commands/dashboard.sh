#
#=========================================================================================
# <Dashboard> Command
#

function dashboard_description () {
  render "Launch the Kubernetes Dashboard for the Kubernetes cluster"
}

function dashboard_command () {
  if ! kubernetes_status; then
    emergency "Kubernetes is not running"
  fi
  if [ "${__environment}" == "local" ]; then
    launch_kubernetes_dashboard
  else
    if ! "${__bin_dir}/kubectl" describe serviceaccount -n kube-system admin-user 1>/dev/null 2>&1; then
      "${__bin_dir}/kubectl" create serviceaccount -n kube-system admin-user
    fi
    if ! "${__bin_dir}/kubectl" describe clusterrolebinding -n kube-system dashboard-admin 1>/dev/null 2>&1; then
      "${__bin_dir}/kubectl" create clusterrolebinding -n kube-system dashboard-admin --clusterrole=cluster-admin --serviceaccount=kube-system:admin-user
    fi

    info "Use the following token to login to the dashboard:"
    add_space
    "${__bin_dir}/kubectl" create token -n kube-system admin-user
    add_space
  fi
}
