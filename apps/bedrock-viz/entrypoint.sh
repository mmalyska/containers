#!/usr/bin/env bash

mkdir /tmp/world
cp -r ${WORLD}/. /tmp/world/

exec \
    /usr/local/bin/bedrock-viz \
    --db /tmp/world \
    --out ${OUT} \
    "$@"
