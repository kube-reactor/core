#
#=========================================================================================
# <Clean> Command
#

function clean_description () {
  render "Cleanup and wipe project resources (VERY DESTRUCTIVE)"
}

function clean_command_environment () {
  force_option
}

function clean_command () {
  if [ ! "$FORCE" ]; then
    confirm
  fi

  destroy_minikube

  rm -f "${__init_file}"

  remove_dns_records

  clean_terraform
  clean_certs
  clean_cache

  run_hook clean
}

function clean_host_command () {
  destroy_host_minikube
  remove_host_dns_records

  run_hook clean_host
  info "Reactor development environment has been cleaned"
}
