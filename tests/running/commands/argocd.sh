#===================
# ArgoCD execution
#===================

function test_argocd_apps () {
  function verify_core_apps () {
    verify_argocd_healthy \
      "argocd/nginx" \
      "argocd/reloader"
  }
  wait verify_core_apps 30
}

function test_seq () {
  tag passthrough argocd

  add_tag app
  run_test test_argocd_apps
}
