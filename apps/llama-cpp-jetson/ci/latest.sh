#!/usr/bin/env bash
# Tracks the latest ggml-org/llama.cpp release tag (e.g. "b9829"). llama.cpp
# cuts a release per merge to master, so this is effectively "current
# upstream" -- matching this repo's usual rolling-tag convention.
#
# This was pinned to b9660 for a while (see git history) over a worry that
# newer builds carried a think-tag-leak regression (ggml-org/llama.cpp#28675,
# first bad commit f8e67fc). Traced that commit: it's a WebUI "Thinking mode
# toggle" change, not a server/API backend change -- this image never builds
# the UI (LLAMA_BUILD_UI=OFF), so it almost certainly doesn't apply here.
# Combined with b9660 itself still showing ~10-15% multi-turn corruption in
# our own testing (unrelated, still-open upstream bug), pinning bought
# little: home-ops has its own reasoning-correctness test suite to catch a
# real regression directly, so tracking upstream and pinning the consumed
# digest at the home-ops end (as usual) is the better default.
set -euo pipefail
curl -fsSL https://api.github.com/repos/ggml-org/llama.cpp/releases/latest | jq -r '.tag_name'
