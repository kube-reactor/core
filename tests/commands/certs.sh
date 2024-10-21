#!/usr/bin/env bash
#
#=========================================================================================
# Test execution
#
set -e

#
# Display current certificates
#
reactor certs --debug

#
# Generate default certificates
#
reactor certs --debug --generate

#
# Generate customized certificates
#
reactor certs --debug --generate --subject="/C=US/ST=NY/L=New York/O=My Project" --days 90
