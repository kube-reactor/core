#
#=========================================================================================
# <System> Command
#

function system_description () {
  echo "Execute a kubectl operation within the reactor environment context"
}
function system_command () {
  kubectl "$@"
  echo ""
}
