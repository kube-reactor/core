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

  destroy_kubernetes_applications
  destroy_kubernetes
  remove_dns_records

  rm -f "${__init_file}"

  clean_provisioner
  clean_certs
  clean_cache

  run_hook clean
  info "Reactor development environment has been cleaned"
}
