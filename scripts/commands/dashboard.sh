#
#=========================================================================================
# <Dashboard> Command
#

function dashboard_description () {
  echo "Launch the Kubernetes Dashboard for the Minikube cluster"
}

function dashboard_command () {
  debug "No operation"
}

function dashboard_host_command () {
  launch_host_minikube_dashboard
}
