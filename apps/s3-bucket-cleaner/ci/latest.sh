#!/usr/bin/env bash
version="$(curl -sX GET "https://api.github.com/repos/aws/aws-cli/tags" | jq --raw-output '.[0].name' 2>/dev/null)"
printf "%s" "${version}"
