#!/usr/bin/env bash

mkdir /tmp/world
cp -r /world/. /tmp/world/

exec \
    /usr/local/bin/bedrock-viz \
    --db /tmp/world \
    --out /out \
    ${BEDROCKVIZ__OPTION} \
    "$@"
