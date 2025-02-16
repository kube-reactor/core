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

  destroy_kubernetes_applications
  destroy_kubernetes
  remove_dns_records

  rm -f "${__init_file}"

  clean_provisioner

  run_hook destroy
  info "Kubernetes environment has been destroyed"
}
