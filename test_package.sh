#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# Test local Krew plugin deployment
#-------------------------------------------------------------------------------
set -e

export __reactor_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export __package_dir="${__reactor_dir}/package"
#
# Generate Krew plugin package files and manifest
#
"${__reactor_dir}/package.sh"
#
# Test Krew plugin installation
#
if kubectl krew list | grep reactor; then
  kubectl krew uninstall reactor
fi
kubectl krew install \
  --manifest="${__package_dir}/reactor.yaml" \
  --archive="${__package_dir}/reactor.tar.gz"
