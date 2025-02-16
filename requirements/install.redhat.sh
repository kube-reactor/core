#!/usr/bin/env bash
#-------------------------------------------------------------------------------
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REACTOR_DIR="$(cd "$(dirname "$SCRIPT_DIR")" && pwd)"

#
# MIN REQUIREMENTS: 
# 
#  * docker
#  * git
#
