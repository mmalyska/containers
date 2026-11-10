#!/usr/bin/env bash
# Newest aws-cli version that is already published as a Docker Hub image tag.
# Reading the registry rather than the aws/aws-cli git tags means we never try
# to build a version whose base image has not been pushed yet.
set -euo pipefail
curl -fsSL "https://hub.docker.com/v2/repositories/amazon/aws-cli/tags?page_size=100&ordering=last_updated" |
  jq -j '
    [.results[].name | select(test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))]
    | sort_by(split(".") | map(tonumber))
    | last'
