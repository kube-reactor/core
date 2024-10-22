#!/usr/bin/env bash
#
#=========================================================================================
# Test preparation
#

#
#=========================================================================================
# Test execution
#

#
# Test running an ArgoCD command after logging in
#
function test_argocd () {
  run reactor argocd app list

  verify_output argocd/nginx
  verify_output argocd/reloader
}
tag argocd app
run_test test_argocd
