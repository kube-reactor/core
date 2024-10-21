#
#=========================================================================================
# <Down> Command
#

function down_description () {
  render "Shut down but do not destroy development environment services"
}

function down_command () {
  stop_kubernetes
  remove_dns_records

  run_hook down
}

function down_host_command () {
  stop_host_kubernetes
  remove_host_dns_records

  run_hook down
  info "Kubernetes environment has been shut down"
}
