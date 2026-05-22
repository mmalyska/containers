# azerothcore-worldserver Container

Custom [AzerothCore](https://www.azerothcore.org/) WotLK worldserver image, compiled from source
with additional modules baked in.

## Included Modules

| Module | Repository |
|--------|-----------|
| [mod-solocraft](https://github.com/azerothcore/mod-solocraft) | Solo difficulty scaling |
| [mod-ah-bot](https://github.com/azerothcore/mod-ah-bot) | Auction house bot |
| [mod-transmog](https://github.com/azerothcore/mod-transmog) | Transmogrification |
| [mod-solo-lfg](https://github.com/azerothcore/mod-solo-lfg) | Solo dungeon finder |

## Usage

```yaml
# Kubernetes example
image: ghcr.io/mmalyska/azerothcore-worldserver:rolling
# Pinned (recommended for production):
image: ghcr.io/mmalyska/azerothcore-worldserver:rolling@sha256:<digest>
```

## Available Tags

| Tag | Description |
|-----|-------------|
| `rolling` | Latest build (rebuilds when upstream AzerothCore commits) |
| `<date>` | Build date snapshot (e.g. `2026-05-22`) |

## Channels

| Channel | Stable | Platforms |
|---------|--------|-----------|
| `stable` | yes | `linux/amd64` |

## Build Details

- **Compiler**: `clang++` with `Boost_USE_STATIC_LIBS=ON`
- **Build type**: `RelWithDebInfo`
- **Base image**: `acore/ac-wotlk-worldserver:master` on Docker Hub
  ([hub.docker.com/r/acore/ac-wotlk-worldserver](https://hub.docker.com/r/acore/ac-wotlk-worldserver)),
  built from [azerothcore/azerothcore-wotlk](https://github.com/azerothcore/azerothcore-wotlk)
  (`apps/docker/Dockerfile`). Pinned by SHA256 digest via Renovate.
- **Source**: All repos pinned to specific commits — update together with the base image digest

## Version Tracking

`ci/latest.sh` queries the latest commit date from `azerothcore/azerothcore-wotlk`. The image
rebuilds hourly when a new commit is detected. The built binary reflects the pinned commit SHAs
in the Dockerfile, not necessarily the very latest upstream commit.

---

## Troubleshooting

### Build fails: `cannot find -l<lib>`

The base image is Ubuntu-based. When upstream upgrades its Ubuntu version, build-time or
link-time dependencies may no longer be transitively provided and must be listed explicitly
in the builder stage.

**Known cases:**

| Library | Added | Reason |
|---------|-------|--------|
| `liblzma-dev` | 2026-05-22 | Ubuntu 22.04 → 24.04 upgrade dropped it as a transitive dep — [azerothcore-wotlk PR #24459](https://github.com/azerothcore/azerothcore-wotlk/pull/24459) |

**How to diagnose**: look for the linker error in the failed CI step:
```
/usr/bin/ld: cannot find -l<name>: No such file or directory
```
Add the corresponding `-dev` package to the `apt-get install` block in the builder stage.

### Runtime crash: missing shared library

The final stage inherits from `acore/ac-wotlk-worldserver` for its runtime. If the base
image's Ubuntu version changes, new shared libraries needed by the worldserver binary may
not be present.

**Known cases:**

| Library | Added | Reason |
|---------|-------|--------|
| `libicu74` | 2026-05-22 | Ubuntu 24.04 base — worldserver now links against ICU 74 |
| `libncurses5-dev` | 2026-05-22 | Ubuntu 24.04 base — ncurses no longer transitively provided |

**How to diagnose**: run the container and look for:
```
error while loading shared libraries: lib<name>.so.<ver>: cannot open shared object file
```
Add the runtime library to the `apt-get install` block in the final stage (the second `FROM`).

### Updating source commit pins

When bumping the base image digest (e.g. via Renovate), also update the commit SHAs in the
`git fetch --depth 1 origin <sha>` lines of the builder stage. Use the current `HEAD` of each
upstream repo at the time of the bump:

```bash
gh api /repos/azerothcore/azerothcore-wotlk/commits/master --jq '.sha'
gh api /repos/azerothcore/mod-solocraft/commits/master --jq '.sha'
gh api /repos/azerothcore/mod-ah-bot/commits/master --jq '.sha'
gh api /repos/azerothcore/mod-transmog/commits/master --jq '.sha'
gh api /repos/azerothcore/mod-solo-lfg/commits/master --jq '.sha'
```
