#
#=========================================================================================
# <Reimage> Command
#

function reimage_description () {
  render "Generate a new Reactor virtualization image version"
  export PASSTHROUGH="1"
}

function reimage_requires_project () {
  return 1
}

function reimage_command () {
  delete_container_environment
  "${__core_dir}/image.sh" "$@"
  exit $?
}
