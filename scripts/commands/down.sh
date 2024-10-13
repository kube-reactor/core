#
#=========================================================================================
# <Down> Command
#

function down_description () {
  echo "Shut down but do not destroy development environment services"
}

function down_command () {
  stop_minikube
  remove_dns_records

  exec_hook down
}

function down_host_command () {
  stop_host_minikube
  remove_host_dns_records

  exec_hook down
  info "Minikube development environment has been shut down"
}
