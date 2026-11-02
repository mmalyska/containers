#!/usr/bin/env bash
# Fails when a tool pinned in this image differs from the version home-ops expects.
# `task talos:install` and `task cilium:install` are skipped only on an exact match;
# otherwise they call sudo, which this image does not have.
set -euo pipefail

dockerfile="apps/dev-workstation/Dockerfile"
home_ops="https://raw.githubusercontent.com/mmalyska/home-ops/main"
status=0

check() {
  local variable=$1 taskfile=$2 pinned expected
  pinned=$(sed -n "s/^ARG ${variable}=//p" "${dockerfile}")
  expected=$(curl -fsSL --retry 3 "${home_ops}/${taskfile}" | sed -n "s/^ *${variable}: *\"\(v[0-9][^\"]*\)\".*/\1/p")

  if [[ -z "${pinned}" || -z "${expected}" ]]; then
    echo "::error::Could not read ${variable}: ${dockerfile} has '${pinned}', home-ops ${taskfile} has '${expected}'"
    status=1
  elif [[ "${pinned}" != "${expected}" ]]; then
    echo "::error::${variable} drifted: ${dockerfile} has ${pinned}, home-ops ${taskfile} has ${expected}"
    status=1
  else
    echo "${variable} matches: ${pinned}"
  fi
}

check TALOS_VERSION .taskfiles/talos/Taskfile.yaml
check CILIUM_VERSION .taskfiles/cilium.yml

exit "${status}"
