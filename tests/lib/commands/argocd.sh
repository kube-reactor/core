#===================
# ArgoCD execution
#===================
#
# Search path
#
# test_{environment}_{phase}
# test_{environment}
# test_{phase}
# test_all
#

function test_argocd_apps () {
  function verify_core_apps () {
    verify_argocd_healthy \
      "argocd/nginx" \
      "argocd/reloader"
  }
  wait verify_core_apps 30
}

function test_running () {
  tag passthrough argocd

  add_tag app
  run_test test_argocd_apps
}
