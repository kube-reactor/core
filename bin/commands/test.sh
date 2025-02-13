#
#=========================================================================================
# <Test> Command
#

function test_description () {
  render "Run phased tests in a clean environment"
  export PASSTHROUGH="1"
}

function test_requires_project () {
  return 1
}

function test_host_command () {
  "${__core_dir}/test" "$@"
  exit $?
}
