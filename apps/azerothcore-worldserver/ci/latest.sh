#!/usr/bin/env bash
version="$(grep -m1 'fetch --depth 1 origin' "$(dirname "$0")/../Dockerfile" \
  | grep -oE '[0-9a-f]{40}')"
printf "%s" "${version}"
