#
#=========================================================================================
# <Sys> Command
#

function sys_description () {
  echo "Execute a kubectl operation within the reactor environment context"
}
function sys_command () {
  "${__binary_dir}/kubectl" "$@"
  echo ""
}
