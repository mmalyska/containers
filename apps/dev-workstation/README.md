# dev-workstation

Shared development image for Coder workspaces and devcontainers, published for
`linux/amd64` and `linux/arm64`. It carries the `devcontainer.metadata` label, so a
repository can use it with `"image": ...` and no `features` block. Reference it by digest.

## Layout

| Path | Contents |
|------|----------|
| `/usr/local/bin` | Release binaries, and symlinks to everything below |
| `/usr/local/go` | Go toolchain |
| `/usr/local/lib/codex` | Codex package, kept whole because `codex` expects its helpers beside it |
| `/usr/local/lib/npm-tools` | Claude Code, prettier, markdownlint-cli |
| `/opt/dev-tools` | Virtualenv with pre-commit, yamllint, mkdocs and its plugins |
| `/etc/skel` | Seed for an empty home volume |

Nothing is installed under `/home/vscode`, because the workspace mounts a volume over it.
The user is `vscode`, UID 1000, and there is no `sudo`. The direnv hook is in
`/etc/bash.bashrc` and the git defaults in `/etc/gitconfig`. Claude Code's auto-updater is
off, since `/usr/local` is not writable: update the image instead.

## Versions

- Release downloads: `# renovate:` comments in the `Dockerfile`.
- Python tools: `python/requirements.in`, compiled with hashes into `python/requirements.txt`:

  ```bash
  cd apps/dev-workstation/python
  uv pip compile --generate-hashes --python-version=3.12 --output-file=requirements.txt requirements.in
  ```

- npm tools: `npm/package.json` and `npm/package-lock.json`.
- npm overrides: `re2js` is pinned in `npm/package.json` because `markdownlint` 0.42.0 pins the
  vulnerable 2.8.6 exactly. Remove the override once a `markdownlint-cli` release carries the fix.
- Open advisories that do not apply, so these packages are not overridden:
  - `minimatch` 10.2.6, from `markdownlint-cli`: GHSA-g3hv-75wg-m249 needs `optimizationLevel` 2 or
    higher, and the CLI keeps the default of 1.
  - `katex` 0.16.47, from `micromark-extension-math`: GHSA-238p-pmpm-9mq7 needs rendering, and
    `markdownlint` only uses the math syntax extension, never the renderer.
- `talosctl` and `cilium` follow `TALOS_VERSION` and `CILIUM_VERSION` in `home-ops`, not
  upstream. Renovate reads those values through custom datasources (`.github/renovate.json5`),
  and `ci/check-version-parity.sh` fails on PRs and in a weekly run if they differ.

## Checksums

`fetch.sh` fails the build on a mismatch. It reads upstream's checksum file, which comes from
the same origin as the download, so it catches corruption rather than a compromised release.

Unverified, because upstream publishes no checksum file: `age`, `egctl`, `direnv`, `cue`,
`shellcheck`. `kubectl-browse-pvc` has none either; its hashes are copied from the krew index
into the `Dockerfile`, so a version bump fails until they are updated by hand.

## Image size

The image is about 3.9 GB on amd64 and 3.8 GB on arm64, uncompressed. Sizes per tool in MB,
measured on 2026-11-02 at the versions first pinned here, to help decide what to trim later.
Renovate does not keep this table current. A dash means not measured on that platform.

| Tool | amd64 | arm64 |
|------|------:|------:|
| Codex package | 517 | 459 |
| coder | 440 | 424 |
| Claude Code | 314 | - |
| Go toolchain | 253 | 248 |
| egctl | 250 | 241 |
| argocd | 240 | 227 |
| helmfile | 173 | 164 |
| Python venv (`/opt/dev-tools`) | 166 | - |
| node, npm | 161 | 161 |
| cilium | 154 | 147 |
| k9s | 126 | 118 |
| terraform | 124 | 114 |
| talosctl | 113 | 106 |
| helm | 64 | 59 |
| kubectl | 60 | 56 |
| task | 50 | 47 |
| stern | 48 | 45 |
| chezmoi | 41 | 38 |
| gh | 40 | 37 |
| kubectl-browse-pvc | 37 | 35 |
| cue | 24 | 22 |
| kubelogin | 22 | 21 |
| gitleaks | 21 | 20 |
| shellcheck | 16 | 53 |
| yq | 14 | 13 |
| kustomize | 13 | 12 |
| goss, dgoss | 13 | 13 |
| bws | 12 | 11 |
| age, age-keygen | 11 | 10 |
| prettier | 10 | - |
| direnv | 9 | 8 |
| jq | 3 | 2 |
