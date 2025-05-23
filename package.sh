#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# Package Krew release files and manifest
#-------------------------------------------------------------------------------
set -e

export __reactor_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export __package_dir="${__reactor_dir}/package"
export __package_files_dir="${__package_dir}/files"

export __core_dir="${__package_files_dir}/core"
export __utility_dir="${__package_files_dir}/utilities"
export __command_dir="${__package_files_dir}/commands"
export __test_dir="${__package_files_dir}/tests"
#
# Prepare package directory
#
rm -Rf "${__package_dir}"
mkdir -p "${__package_files_dir}"
#
# Create tar release from package files
#
mkdir "${__core_dir}"
mkdir "${__utility_dir}"
mkdir "${__command_dir}"
mkdir "${__test_dir}"

cp "${__reactor_dir}/VERSION" "${__package_files_dir}"
cp "${__reactor_dir}/LICENSE" "${__package_files_dir}"
cp "${__reactor_dir}"/*.* "${__package_files_dir}"

cp "${__reactor_dir}/bin/reactor" "${__package_files_dir}"
cp "${__reactor_dir}/bin/kubectl-reactor" "${__package_files_dir}"
cp -R "${__reactor_dir}/bin/core"/* "${__core_dir}"
cp "${__reactor_dir}/bin/utilities"/*.sh "${__utility_dir}"
cp "${__reactor_dir}/bin/utilities"/*.py "${__utility_dir}"
cp -R "${__reactor_dir}/bin/utilities/template"/* "${__utility_dir}"
cp "${__reactor_dir}/bin/commands"/*.sh "${__command_dir}"
cp -R "${__reactor_dir}/tests"/* "${__test_dir}"

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
