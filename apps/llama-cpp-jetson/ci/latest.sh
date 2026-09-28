#!/usr/bin/env bash
# Deliberately pinned, not tracking upstream latest. b9660 (2026-06-16) is
# the earliest llama.cpp release that carries both fixes this image exists
# for: ggml-org/llama.cpp#24234 (think-tag leak into `content`, merged
# 2026-06-06) and the LFM2 tool-call double-escaping fix shipped in b9660
# itself. Anything newer hasn't been vetted against nv1 — bump this by hand
# (and re-run the plan's Test 1/Test 2 checks) rather than floating it.
printf "%s" "b9660"
