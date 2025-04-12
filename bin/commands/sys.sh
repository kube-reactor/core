#
#=========================================================================================
# <Sys> Command
#

function sys_description () {
  render "DEPRECATED: Refer to kube command"
}

function sys_command () {
  run_subcommand kube "$@"
}
