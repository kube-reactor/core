#!/usr/bin/env bash
#
#=========================================================================================
# Test preparation
#

#
# Remove any previous ubuntu:22.04 image
#
#docker image rm ubuntu:22.04 2>/dev/null

#
#=========================================================================================
# Test execution
#

#
# Run container command without image available
#
#reactor exec ubuntu:22.04 ls -al --wait=10

#
# Run container command with image and default timeout
#
#reactor exec ubuntu:22.04 ls -al
