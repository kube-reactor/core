#!/usr/bin/env bash
#
#=========================================================================================
# Test preparation
#

#
#=========================================================================================
# Test execution
#
set -e

#
# Return a list of charts in the ArgoCD namespace
#
reactor helm list -n argocd --debug

#
# Return information about the ArgoCD chart in the ArgoCD namespace
#
reactor helm get all argocd -n argocd --debug
