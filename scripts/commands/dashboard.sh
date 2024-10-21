#
#=========================================================================================
# <Dashboard> Command
#

function dashboard_description () {
  render "Launch the Kubernetes Dashboard for the Kubernetes cluster"
}

function dashboard_host_command () {
  if ! kubernetes_status; then
    emergency "Kubernetes is not running"
  fi
  launch_host_kubernetes_dashboard
}
