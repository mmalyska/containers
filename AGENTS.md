# AGENTS.md

This file provides context for AI coding agents (Claude Code, Codex, and others) working in this repository.

## Project Overview

Container image building and publishing repository. Builds and publishes multi-platform Docker
images to GitHub Container Registry (`ghcr.io/mmalyska/*`). Forked from
[onedr0p/containers](https://github.com/onedr0p/containers).

## Apps

| App | Description | Platforms |
|-----|-------------|-----------|
| `argocd-secret-replacer` | Replaces keys with values from secret providers (e.g. SOPS) for ArgoCD | amd64, arm64 |
| `dev-workstation` | Shared development image for Coder workspaces and devcontainers | amd64, arm64 |
| `nextcloud` | Official Nextcloud fpm-alpine plus ffmpeg and exiftool (previews, Memories) | amd64 |
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
- `upstream` (optional): where the upstream project says what changed in a version, for apps
  whose version follows an upstream one. `releaseNotes` is required in it, `compare` optional;
  both are `https://` URL templates where `{version}` is the image version and
  `{previousVersion}` the version of the image's previous release. Omit it for apps with no
  upstream. See [Release notes](#release-notes).

  ```json
  "upstream": {
    "releaseNotes": "https://github.com/aws/aws-cli/blob/{version}/CHANGELOG.rst",
    "compare": "https://github.com/aws/aws-cli/compare/{previousVersion}...{version}"
  }
  ```

## Version Tracking Flow

How an app's version moves from upstream to a published image tag:

1. **`ci/latest.sh`** — prints the current upstream version to stdout (no newline).
   The string can be a semver, date, or commit SHA — anything unique per release.
   Called by CI as `./apps/<name>/ci/latest.sh "<channel>" "<stable>"`.

2. **`index.mjs` (`changes` export)** — runs `latest.sh` to get `upstreamVersion`,
   then queries GHCR for the non-`rolling` tag on the published `rolling` image
   (`publishedVersion`). If they differ, the app is queued for a rebuild.
   Comparison is **string equality** — no semver parsing.

3. **CI build** — passes the version as a Docker build arg:
   ```
   VERSION=<upstreamVersion>
   CHANNEL=<channel>
   ```

4. **Dockerfile** — receives it via `ARG VERSION` and uses `${VERSION}` wherever
   the upstream version is needed (download URL, git checkout, etc.).

5. **Published tags** — the built image is tagged `rolling` + `<upstreamVersion>`.
   Next hourly run compares the new `publishedVersion` against `latest.sh` output.

### Implications for `latest.sh`

- Return whatever string uniquely identifies the built artifact — semver, date, or SHA.
- If the upstream is a Git repo tracked by commit, return the full commit SHA so
  the comparison is unambiguous (dates collide; short SHAs are not canonical).
- Keep it idempotent: same upstream state → same output → no spurious rebuilds.

## Conventions

- CUE schema at `metadata.rules.cue` validates all `metadata.json` — always run `cue vet` before committing
- Goss tests in `ci/goss.yaml` validate container behavior after build
- Config volume inside containers is hardcoded to `/config`
- Multi-platform channels build each platform on its own native runner, without QEMU (see [Multi-platform builds](#multi-platform-builds))
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

`action-image-build.yaml` is the reusable build workflow. `pr-validate.yaml` calls its local
copy, so a PR tests its own changes to it, but only when the PR also changes something under
`apps/`. The release workflows call `@main`, so a change to it takes effect for them on merge.

### Multi-platform builds

`prepare-matrix` in `action-image-build.yaml` expands each channel into one `build-and-test`
job per platform: `ubuntu-latest` for `linux/amd64`, `ubuntu-24.04-arm` for `linux/arm64`.

- **Single-platform channel**: the job builds, runs Goss, and pushes `:rolling` and `:<version>`.
- **Multi-platform channel**: each platform's job builds natively, runs Goss on that platform's
  image, pushes by digest with no tag, and uploads the digest as an artifact. `merge-manifests`
  then publishes the merged manifest under `:rolling` and `:<version>`.
- **Failure**: a platform that fails its build or Goss test uploads no digest, so `merge-manifests`
  publishes nothing for that channel and the existing tags stay where they are. The platform
  images already pushed stay in GHCR, untagged. Other apps are not affected.
- **Without a push** (PRs): each platform builds and runs Goss, and `merge-manifests` is skipped,
  so the merge is only exercised by a real push.
- **Labels**: the "Setup workflow Variables" step builds the image labels and writes them to the
  job summary, so a PR run shows the labels a release would get.

## Release notes

Every pushed image version gets a GitHub release in this repository, so Renovate PRs that
update a `ghcr.io/mmalyska/*` image show release notes:

- Every image carries `org.opencontainers.image.source` (this repository) and
  `org.opencontainers.image.revision` (the commit it was built from). Renovate reads them from
  the newest stable tag to find the repository
  ([docker datasource docs](https://docs.renovatebot.com/modules/datasource/docker/)).
  Base images also carry them without the `.base` prefix, because Renovate reads only those.
- The `publish-releases` job of `action-image-build.yaml` runs
  `.github/scripts/publish-release.sh` for each image of a push build. It publishes the release
  `<imageName> <version>`, tagged `<imageName>-<version>` at the built commit, which is the tag
  form Renovate matches to the image version. The release links the upstream notes (from
  `upstream` in `metadata.json`) and lists the commits to `apps/<app>/` since the image's
  previous release.
- A rebuild of a version that already has a release appends its commits to that release. The
  git tag is not moved.
- The release is published only if the pushed `<image>:<version>` carries the run's commit as
  its revision, so a failed image gets no release.
- `<!-- built-from: <sha> -->` markers in a release body record the commits it covers. Keep
  them when editing a release by hand: the next build starts its commit list from the last one.
- Try it without publishing: `DRY_RUN=true GITHUB_REPOSITORY=mmalyska/containers APP=<app>
  IMAGE_NAME=<image> VERSION=<version> IMAGE=ghcr.io/mmalyska/<image> SHA=$(git rev-parse HEAD)
  RUN_URL=<any> ./.github/scripts/publish-release.sh` (needs `gh` signed in).

## Tag Generation

| Channel `stable` | Base | Example Tag |
|-----------------|------|-------------|
| `true` | `false` | `argocd-secret-replacer:1.2.3`, `argocd-secret-replacer:rolling` |
| `false` | `false` | `argocd-secret-replacer-dev:1.2.3`, `argocd-secret-replacer-dev:rolling` |

## Security

**Never store secrets, credentials, tokens, API keys, or other sensitive data in:**
- This file (`AGENTS.md`)
- Memory files (`.claude/MEMORY.md`)
- Any committed file in this repository
- GitHub Actions workflow files (use GitHub Secrets instead)

Use `.private/` (gitignored) for any local sensitive files needed during development.
