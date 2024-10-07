#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# Package Krew release files and manifest
#-------------------------------------------------------------------------------
set -e

export __reactor_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export __package_dir="${__reactor_dir}/package"
export __package_files_dir="${__package_dir}/files"
#
# Prepare package directory
#
rm -Rf "${__package_dir}"
mkdir -p "${__package_files_dir}"
#
# Create tar release from package files
#
cp -R "${__reactor_dir}/scripts" "${__package_files_dir}/scripts"
cp "${__reactor_dir}/requirements.txt" "${__package_files_dir}/requirements.txt"
cp "${__reactor_dir}/VERSION" "${__package_files_dir}/VERSION"
cp "${__reactor_dir}/LICENSE" "${__package_files_dir}/LICENSE"

cd "${__package_files_dir}"
tar -cvzf "${__package_dir}/reactor.tar.gz" *
#
# Prepare release manifest
#
cp "${__reactor_dir}/reactor.template.yaml" "${__package_dir}/reactor.yaml"

VERSION="$(cat "${__package_files_dir}/VERSION")"
SHA256="$(sha256sum "${__package_dir}/reactor.tar.gz" | sed 's/\s.*$//')"

sed -i "s/!!!VERSION!!!/${VERSION}/" "${__package_dir}/reactor.yaml"
sed -i "s/!!!SHA256!!!/${SHA256}/" "${__package_dir}/reactor.yaml"
