#!/usr/bin/env bash
version="$(curl -sX GET "https://api.github.com/repos/azerothcore/azerothcore-wotlk/commits?per_page=1&sha=master" 2>/dev/null \
  | jq -r '.[0].sha')"
printf "%s" "${version}"
