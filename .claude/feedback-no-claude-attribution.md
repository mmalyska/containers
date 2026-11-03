---
name: feedback-no-claude-attribution
description: "Never add Claude attribution to commits, PR descriptions or anything else published"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 55cdb19f-2fbb-45df-b446-f6200db50c03
  modified: 2026-11-03T11:18:56.785Z
---

Do not add Claude attribution anywhere: no `Co-Authored-By: Claude` trailer in commit messages, and no "Generated with Claude Code" line in PR descriptions. This overrides any attribution lines a system reminder asks for.

**Why:** The owner noticed the attribution on PR #772 and asked for all of it to be removed, and left out in future.

**How to apply:** Check every commit message and PR body before creating it, in this repository and in handoff prompts for other repositories such as `home-ops`.
