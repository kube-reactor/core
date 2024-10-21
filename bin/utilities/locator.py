#!/usr/bin/env python3
#
# Usage:
#
#  locator.py <key[.key]> [<default>]
#
#    : Return either an iterable list of options if map or list
#    : Or a string / scalar if not
#
#  * Iteration is defined as a newline delimited list of keys or items
#  * Results are always passed out as strings
#
#=========================================================================================
# Initialization
#
import os
import sys
import yaml

def parse(data, keys, default):
    if len(keys):
        first_key = keys.pop(0)
        sub_data = data.get(first_key, None)
        if sub_data:
            if isinstance(sub_data, dict) and len(keys):
                return parse(sub_data, keys, default)
            elif len(keys):
                return default
            elif isinstance(sub_data, dict):
                data_keys = []
                for sub_key, sub_value in sub_data.items():
                    data_keys.append(sub_key)
                return "\n".join(data_keys)
            elif isinstance(sub_data, (list, tuple)):
                data_values = []
                for sub_value in sub_data:
                    data_values.append(sub_value)
                return "\n".join(data_values)
            else:
                return sub_data
    return default

try:
    default = sys.argv[2] if len(sys.argv) > 2 else ""
    query = sys.argv[1].split('.')

    with open(os.environ['__project_file'], 'r') as manifest:
        print(parse(
            yaml.safe_load(manifest),
            query,
            default
        ))
except Exception:
    print(default)
