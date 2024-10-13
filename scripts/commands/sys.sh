#
#=========================================================================================
# <Sys> Command
#

function sys_description () {
  echo "Execute a kubectl operation within the reactor environment context"
  export PASSTHROUGH="1"
}

function sys_command () {
  "${__binary_dir}/kubectl" "$@"
  echo ""
}
