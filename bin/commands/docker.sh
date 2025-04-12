#
#=========================================================================================
# <Docker> Command
#

function docker_description () {
  render "Execute a Docker operation within the reactor environment context"
  export PASSTHROUGH="1"
}

function docker_command () {
  docker "$@"
  add_space
}
