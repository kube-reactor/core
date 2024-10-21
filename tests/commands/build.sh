#!/usr/bin/env bash
#
#=========================================================================================
# Test execution
#
set -e

#
# Build all projects from scratch
#
reactor build --debug --no-cache

#
# Build all projects using cache
#
reactor build --debug
