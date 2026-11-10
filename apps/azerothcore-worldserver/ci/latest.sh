#!/usr/bin/env bash
# Version = the azerothcore-wotlk commit pinned in the Dockerfile. Renovate bumps
# it (with the module SHAs and base digest) once a week, so this only changes
# when that PR is merged instead of on every upstream master commit.
set -euo pipefail
dir="$(dirname "$0")"
sed -n 's/^ARG AZEROTHCORE_SHA=\([0-9a-f]\{40\}\)$/\1/p' "${dir}/../Dockerfile" | tr -d '\n'
