#!/usr/bin/env bash

aws s3api list-objects-v2 --bucket "$BUCKET" --prefix "$S3_PREFIX" --query \
     "Contents[?LastModified<=\`$(date -d "$OLDER_THAN" '+%Y-%m-%d')\`][].{object: Key}" \
  | jq -r '.[].object' \
  | xargs -I {} aws s3api delete-object --bucket "$BUCKET" --key {}
