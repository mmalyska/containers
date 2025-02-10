#!/usr/bin/env bash
version="$(curl -sX GET "https://api.vintagestory.at/lateststable.txt" 2>/dev/null)"
version="${version#*v}"
printf "%s" "${version}"
