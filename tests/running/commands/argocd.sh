#=================
# Test execution
#=================

function test_argocd_apps () {
  run reactor argocd app list

  verify_output "^argocd/nginx.+Synced.+Healthy"
  verify_output "^argocd/reloader.+Synced.+Healthy"
}

function test_seq () {
  tag passthrough argocd

  add_tag app
  run_test test_argocd_apps
}
