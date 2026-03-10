# CLAUDE.md

This file provides context for Claude Code when working in this repository.

## Project Overview

Container image building and publishing repository. Builds and publishes multi-platform Docker
images to GitHub Container Registry (`ghcr.io/mmalyska/*`). Forked from
[onedr0p/containers](https://github.com/onedr0p/containers).

## Apps

| App | Description | Platforms |
|-----|-------------|-----------|
| `argocd-secret-replacer` | Replaces keys with values from secret providers (e.g. SOPS) for ArgoCD | amd64, arm64 |
| `s3-bucket-cleaner` | Cleans old files from AWS S3 buckets | amd64, arm64 |
| `vintagestory` | VintageStory game server | amd64 |

## Repository Structure

```
apps/<name>/
├── Dockerfile          # Container build definition
├── metadata.json       # App metadata (channels, platforms, tests)
├── README.md           # App-specific documentation
├── entrypoint.sh       # (optional) custom entrypoint
└── ci/
    ├── latest.sh       # Fetches latest upstream version
    └── goss.yaml       # Container tests (Goss framework)
```

Top-level files:
- `metadata.rules.cue` — CUE schema that validates all `metadata.json` files
- `Taskfile.yml` — local development task runner
- `.github/workflows/` — CI/CD pipelines

## Key Commands

```bash
# Test a container locally (downloads Goss, builds image, runs tests)
task APP=argocd-secret-replacer CHANNEL=stable test

# Validate metadata schema manually
cue vet --schema '#Spec' ./apps/<name>/metadata.json metadata.rules.cue

# List available tasks
task
```

## Adding a New Container App

1. Create `apps/<name>/` directory
2. Add these files (copy from an existing app as a template):
   - `Dockerfile`
   - `metadata.json` (validated against `metadata.rules.cue`)
   - `ci/latest.sh` (script to fetch latest upstream version)
   - `ci/goss.yaml` (Goss test specs)
   - `README.md`
3. Validate schema: `cue vet --schema '#Spec' ./apps/<name>/metadata.json metadata.rules.cue`
4. Test locally: `task APP=<name> CHANNEL=stable test`

## metadata.json Format

```json
{
  "app": "my-app",
  "base": false,
  "channels": [
    {
      "name": "stable",
      "description": "Description of the image",
      "platforms": ["linux/amd64", "linux/arm64"],
      "stable": true,
      "tests": {
        "enabled": true,
        "type": "cli"
      }
    }
  ]
}
```

- `base`: set `true` only for base images (affects tag generation)
- `stable`: affects tag naming — stable channels omit the channel name from the tag
- `tests.type`: `"cli"` (run with `tail -f /dev/null`) or `"web"` (service stays running)

## Conventions

- CUE schema at `metadata.rules.cue` validates all `metadata.json` — always run `cue vet` before committing
- Goss tests in `ci/goss.yaml` validate container behavior after build
- Config volume inside containers is hardcoded to `/config`
- Multi-platform support via Docker Buildx (QEMU emulation for arm64)
- Images are pinned by SHA256 digest for immutability — use `image:tag@sha256:...` references
- Renovate bot runs hourly and auto-creates PRs for dependency updates
- Tool versions in Dockerfiles are marked with `# renovate:` comments for automated updates

## CI/CD Pipelines

| Workflow | Trigger | Action |
|----------|---------|--------|
| `release-schedule.yaml` | Hourly + manual | Checks upstream versions, builds & pushes if changed |
| `image-rebuild.yaml` | Push to main (Dockerfile/app changes) | Builds & pushes changed images |
| `pr-validate.yaml` | Pull requests | Validates changed apps, builds but does NOT push |
| `release-manual.yaml` | Manual dispatch | Build specific apps or ALL, optionally push |
| `scheduled-renovate.yaml` | Hourly | Runs Renovate dependency update bot |

## Tag Generation

| Channel `stable` | Base | Example Tag |
|-----------------|------|-------------|
| `true` | `false` | `argocd-secret-replacer:1.2.3`, `argocd-secret-replacer:rolling` |
| `false` | `false` | `argocd-secret-replacer-dev:1.2.3`, `argocd-secret-replacer-dev:rolling` |

## Security

**Never store secrets, credentials, tokens, API keys, or other sensitive data in:**
- This file (`CLAUDE.md`)
- Memory files (`.claude/MEMORY.md`)
- Any committed file in this repository
- GitHub Actions workflow files (use GitHub Secrets instead)

Use `.private/` (gitignored) for any local sensitive files needed during development.
