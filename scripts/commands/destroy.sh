#
#=========================================================================================
# <Destroy> Command
#

function destroy_description () {
  echo "Shut down and destroy Minikube development environment (DESTRUCTIVE)"
}

function destroy_command_environment () {
  parse_flag --force \
    FORCE \
    "Force execution without confirming"
}

function destroy_command () {
  if [ ! "$FORCE" ]; then
    confirm
  fi

  destroy_minikube

  rm -f "${__init_file}"

  remove_dns_records
  clean_terraform

  exec_hook destroy
}

function destroy_host_command () {
  destroy_host_minikube
  remove_host_dns_records

  exec_hook destroy_host
  info "Minikube development environment has been destroyed"
}
