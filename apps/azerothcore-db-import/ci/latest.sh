#!/usr/bin/env bash
version="$(curl -sX GET "https://api.github.com/repos/azerothcore/azerothcore-wotlk/commits?per_page=1&sha=master" 2>/dev/null \
  | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['commit']['committer']['date'][:10])")"
printf "%s" "${version}"
