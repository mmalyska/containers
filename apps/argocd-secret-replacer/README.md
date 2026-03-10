# argocd-secret-replacer Container

Container image for [argocd-secret-replacer](https://github.com/mmalyska/argocd-secret-replacer),
a tool that replaces `keys` with values from a secret provider (e.g. SOPS) in ArgoCD workflows.

## Usage

```yaml
# Kubernetes / ArgoCD example
image: ghcr.io/mmalyska/argocd-secret-replacer:rolling
# Pinned (recommended for production):
image: ghcr.io/mmalyska/argocd-secret-replacer:rolling@sha256:<digest>
```

## Available Tags

| Tag | Description |
|-----|-------------|
| `rolling` | Latest stable release (updates automatically) |
| `<version>` | Specific version (e.g. `1.2.3`) |

Always pin to the SHA256 digest for immutable deployments:

```
ghcr.io/mmalyska/argocd-secret-replacer:<tag>@sha256:<digest>
```

## Channels

| Channel | Stable | Platforms |
|---------|--------|-----------|
| `stable` | yes | `linux/amd64`, `linux/arm64` |

## Platforms

- `linux/amd64`
- `linux/arm64`
