#=================
# Helm execution
#=================

function test_helm_charts () {
  function verify_core_charts () {
    verify_helm_deployed argocd argocd
  }
  wait verify_core_charts 30
}

function test_seq () {
  tag passthrough helm

  add_tag chart
  run_test test_helm_charts
}
