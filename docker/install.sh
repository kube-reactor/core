#!/bin/bash
#-------------------------------------------------------------------------------
set -e

for requirements in "/reactor/share/"*.txt; do
  pip3 install --no-cache-dir -r "$requirements"
done

for script in "/reactor/share/"*.sh; do
  "$script"
done
