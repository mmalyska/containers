# dev-workstation

Shared development image for Coder workspaces and devcontainers, published for
`linux/amd64` and `linux/arm64`. It carries the `devcontainer.metadata` label, so a
repository can use it with `"image": ...` and no `features` block. Reference it by digest.

## Tools

`mise.toml` lists every tool and its version, and Renovate bumps them. To add a tool, add a
line there and a check in `ci/goss.yaml`. `apt` in the `Dockerfile` only provides the OS.

Image tools are in `/opt/mise`, read-only, and their shims are linked into `/usr/local/bin`.
A workspace mounts one volume on `/home/vscode` and one on `/workspaces`, the default directory,
so the image installs nothing under either. The volumes must be writable by UID 1000.

Caches for Go, npm, uv, pip, Helm, Terraform, pre-commit and mise go to `/cache`, so they stay out
of backups and can be deleted at any time. On Kubernetes, mount an `emptyDir` there. Devcontainers
get a shared `dev-workstation-cache` volume from the image label.

There is no `sudo`, so add a tool with `mise use -g <tool>`, or a `mise.toml` in a repository
and `mise install`. These go to the home volume, and a repository's versions take priority over
the image's in interactive shells. Scripts get them through `mise exec`. `apt` packages have to be
added to the image.

The user is `vscode`, UID 1000. The mise and direnv hooks are in
`/etc/bash.bashrc` and the git defaults in `/etc/gitconfig`. Claude Code's auto-updater is
off, since `/opt/mise` is not writable: update the image instead.
