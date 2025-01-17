#!/bin/bash
#-------------------------------------------------------------------------------
set -e

if compgen -G "/reactor/share/"*.txt >/dev/null; then
  for requirements in "/reactor/share/"*.txt; do
    pip3 install --no-cache-dir -r "$requirements"
  done
fi

if compgen -G "/reactor/share/"*.sh >/dev/null; then
  for script in "/reactor/share/"*.sh; do
    "$script"
  done
fi
