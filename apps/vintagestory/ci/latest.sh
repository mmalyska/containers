#!/usr/bin/env bash
version="$(curl -sX GET "https://mods.vintagestory.at/api/gameversions" | jq --raw-output '.gameversions[0].name' 2>/dev/null)"
version="${version#*v}"
printf "%s" "${version}"
