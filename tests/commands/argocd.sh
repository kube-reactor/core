#!/usr/bin/env bash
#
#=========================================================================================
# Test execution
#
set -e

#
# Test running an ArgoCD command after logging in
#
reactor argocd app list
