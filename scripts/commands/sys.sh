#
#=========================================================================================
# <Sys> Command
#

function sys_description () {
  echo "Execute a kubectl operation within the reactor environment context"
}
function sys_command () {
  kubectl "$@"
  echo ""
}
