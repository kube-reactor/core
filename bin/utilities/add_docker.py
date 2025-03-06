#!/usr/bin/env python3
#
# Usage:
#
#  add_docker.py project_name remote_git_url git_reference docker_dir docker_tag
#
#    : Add a new Docker project to the Reactor project manifest
#
# =========================================================================================
# Initialization
#
import os
import sys
import ruamel.yaml

project_name = sys.argv[1]
remote_git_url = sys.argv[2]
git_reference = sys.argv[3]
docker_dir = sys.argv[4]
docker_tag = sys.argv[5]

yaml = ruamel.yaml.YAML()
yaml.preserve_quotes = True
yaml.preserve_comments = True
yaml.default_flow_style = False

# Load project manifest
with open(os.environ["__project_manifest"], "r") as manifest:
    manifest_data = yaml.load(manifest)

# Add Docker project
manifest_data["docker"].insert(
    0,
    project_name,
    {
        "remote": remote_git_url,
        "reference": git_reference,
        "docker_dir": docker_dir,
        "docker_tag": docker_tag,
    },
)

# Save updated project manifest
with open(os.environ["__project_manifest"], "w") as manifest:
    yaml.dump(manifest_data, manifest)
