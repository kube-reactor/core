#
#=========================================================================================
# <Dashboard> Command
#

function dashboard_description () {
  render "Launch the Kubernetes Dashboard for the Minikube cluster"
}

function dashboard_host_command () {
  if ! minikube_status; then
    emergency "Minikube is not running"
  fi
  launch_host_minikube_dashboard
}
