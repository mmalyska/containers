#!/usr/bin/env bash
# Version = digest of the acore/ac-wotlk-authserver base image pinned in the
# Dockerfile. Renovate bumps it once a week, so this only changes when that PR
# is merged instead of on every upstream master commit.
set -euo pipefail
dir="$(dirname "$0")"
sed -n 's|^FROM acore/ac-wotlk-authserver:master@sha256:\([0-9a-f]\{64\}\).*|\1|p' "${dir}/../Dockerfile" | tr -d '\n'
