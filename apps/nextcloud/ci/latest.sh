#!/usr/bin/env bash
# Latest Nextcloud release of one major line that has an fpm-alpine image on
# Docker Hub (e.g. "35.0.2"). The major is pinned on purpose: Nextcloud only
# upgrades one major version at a time and the consuming chart has to be moved
# deliberately, so this must never jump to the next major by itself. Bump
# MAJOR here when home-ops is ready for the next one.
set -euo pipefail
MAJOR=35
curl -fsSL "https://hub.docker.com/v2/repositories/library/nextcloud/tags?name=${MAJOR}.&page_size=100" |
  jq -j --arg major "${MAJOR}" '
    [.results[].name
      | select(test("^" + $major + "\\.[0-9]+\\.[0-9]+-fpm-alpine$"))
      | sub("-fpm-alpine$"; "")]
    | sort_by(split(".") | map(tonumber))
    | last'
