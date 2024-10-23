#!/usr/bin/env bash
#
#=========================================================================================
# Test execution
#

#
# Test running an ArgoCD command after logging in
#
function test_argocd () {
  run reactor argocd app list

  verify_output "^argocd/nginx.+Synced.+Healthy"
  verify_output "^argocd/reloader.+Synced.+Healthy"
}

function test_seq () {
  tag argocd app
  run_test test_argocd
}
