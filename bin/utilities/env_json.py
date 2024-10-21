#!/usr/bin/env python3
#
# Usage:
#
#  env_json.py
#
#    : Return a JSON string of all registered environment variables
#
#=========================================================================================
# Initialization
#
import os
import json

environment = {}

skip_vars = [
  "HOSTNAME",
  "PATH",
  "PWD",
  "USER",
  "HOME",
  "SHELL"
]

for name, value in os.environ.items():
  if not name.startswith('TF_VAR_') and name not in skip_vars:
    environment[name] = value.replace('${', '$${')

print(json.dumps(environment, indent=2))
