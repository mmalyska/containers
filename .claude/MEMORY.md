# Project Memory: containers

Versioned memory for Claude Code. Linked from the devcontainer into
`/home/vscode/.claude/projects/-workspaces-containers/memory/` via postCreateCommand in
`.devcontainer/devcontainer.json`.

## Repository Purpose

Container image building & publishing repo. Builds multi-platform Docker images and publishes
to GHCR (`ghcr.io/mmalyska/*`). Forked from onedr0p/containers.

## Current Apps

- `argocd-secret-replacer` — ArgoCD SOPS secret replacement tool (amd64 + arm64)
- `s3-bucket-cleaner` — AWS S3 bucket cleanup utility (amd64 + arm64)
- `vintagestory` — VintageStory game server (amd64 only)

## Key File Paths

- `CLAUDE.md` — Full Claude Code context (commands, conventions, CI/CD overview)
- `metadata.rules.cue` — CUE schema validating all `apps/*/metadata.json` files
- `Taskfile.yml` — Local dev task runner
- `.github/workflows/` — CI/CD pipelines (release-schedule, image-rebuild, pr-validate, etc.)
- `apps/<name>/ci/latest.sh` — Fetches latest upstream version for each app
- `apps/<name>/ci/goss.yaml` — Container test specs

## Common Commands

```bash
# Build and test a container locally
task APP=argocd-secret-replacer CHANNEL=stable test

# Validate metadata schema
cue vet --schema '#Spec' ./apps/<name>/metadata.json metadata.rules.cue
```

## Conventions

- All `metadata.json` files validated by CUE schema before builds
- Goss framework used for container testing
- Config volume inside containers always at `/config`
- Images pinned by SHA256 digest for immutability
- Renovate bot auto-updates dependencies hourly
- `.private/` directory is gitignored — safe for local sensitive files

## Security Reminder

**Never store secrets, tokens, credentials, or sensitive data in this file or any committed file.**
Use GitHub Secrets for CI/CD credentials. Use `.private/` (gitignored) for local sensitive files.
