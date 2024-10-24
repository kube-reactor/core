#==================
# Build execution
#==================

function verify_build () {
  debug "TODO: Check Docker images and Helm charts"
}

function build_no_cache () {
  run reactor build --debug --no-cache
  verify_build
}

function build_no_cache () {
  run reactor build --debug
  verify_build
}

function test_seq () {
  tag build
  run_test build_no_cache
  run_test build_cache
}
