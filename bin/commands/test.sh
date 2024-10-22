#
#=========================================================================================
# <Test> Command
#

function test_description () {
  render "Run phased tests in a clean environment"
  export PASSTHROUGH="1"
}

function test_check_project () {
  return 0
}

function test_host_command () {
  env -i "${__binary_dir}/reactor-test" "$@"
  exit $?
}
