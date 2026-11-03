# dev-workstation

Shared development image for Coder workspaces and devcontainers, published for
`linux/amd64` and `linux/arm64`. It carries the `devcontainer.metadata` label, so a
repository can use it with `"image": ...` and no `features` block. Reference it by digest.

## Tools

`mise.toml` lists every tool and its version, and Renovate bumps them. To add a tool, add a
line there and a check in `ci/goss.yaml`. `apt` in the `Dockerfile` only provides the OS.

mise installs into `/opt/mise`, and its shims are linked into `/usr/local/bin`. Nothing is
installed under `/home/vscode`, because the workspace mounts a volume over it.

The user is `vscode`, UID 1000, and there is no `sudo`. The direnv hook is in
`/etc/bash.bashrc` and the git defaults in `/etc/gitconfig`. Claude Code's auto-updater is
off, since `/opt/mise` is not writable: update the image instead.
