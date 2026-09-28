#!/usr/bin/env bash
# Tracks the latest ggml-org/llama.cpp release tag (e.g. "b9829"). llama.cpp
# cuts a release per merge to master, so this is effectively "current
# upstream", matching this repo's usual rolling-tag convention — pin the
# resulting image by digest at the consumer (home-ops) as usual.
set -euo pipefail
curl -fsSL https://api.github.com/repos/ggml-org/llama.cpp/releases/latest | jq -r '.tag_name'
