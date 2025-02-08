#==================
# Build execution
#==================
#
# Search path
#
# test_{environment}_{phase}
# test_{environment}
# test_{phase}
# test_all
#

function verify_build () {
  debug "TODO: Check Docker images and Helm charts"
}

function build_no_cache () {
  run_reactor build --debug --no-cache
  verify_build
}

function build_cache () {
  run_reactor build --debug
  verify_build
}

function test_all () {
  tag build
  run_test build_no_cache
  run_test build_cache
}
