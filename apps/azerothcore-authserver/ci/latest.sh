#!/usr/bin/env bash
# All azerothcore images are released together as one WoW server version: the
# azerothcore-wotlk commit pinned in the worldserver Dockerfile. Renovate bumps
# it (with every base digest and module SHA) in one weekly PR, so this only
# changes when that PR is merged.
set -euo pipefail
dir="$(dirname "$0")"
sed -n 's/^ARG AZEROTHCORE_SHA=\([0-9a-f]\{40\}\)$/\1/p' "${dir}/../../azerothcore-worldserver/Dockerfile" | tr -d '\n'
