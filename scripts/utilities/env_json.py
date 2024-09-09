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

for name, value in os.environ.items():
  if not name.startswith('TF_VAR_'):
    environment[name] = value

print(json.dumps(environment, indent=2))
