#
#=========================================================================================
# <Destroy> Command
#

function destroy_description () {
  render "Shut down and destroy Kubernetes environment (DESTRUCTIVE)"
}

function destroy_command_environment () {
  force_option
}

function destroy_command () {
  if [ ! "$FORCE" ]; then
    confirm
  fi

  destroy_kubernetes

  rm -f "${__init_file}"

  remove_dns_records
  clean_terraform

  run_hook destroy
}

function destroy_host_command () {
  destroy_host_kubernetes
  remove_host_dns_records

  run_hook destroy_host
  info "Kubernetes environment has been destroyed"
}
