# One stage per tool: BuildKit fetches them in parallel, and a version bump
# rebuilds and re-pulls only that tool's stage and layer. Each stage installs
# under $OUT, which the final stage copies to /usr/local. Nothing goes under
# /home/vscode: the workspace mounts a volume over the home directory.

FROM ubuntu:24.04@sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852 AS os
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      bash-completion \
      bind9-dnsutils \
      ca-certificates \
      curl \
      fd-find \
      gettext-base \
      git \
      ipcalc \
      libatomic1 \
      locales \
      nano \
      openssh-client \
      python3 \
      python3-pip \
      python3-venv \
      ripgrep \
      unzip \
      vim \
    && locale-gen en_US.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

FROM os AS fetcher
ENV OUT=/out
COPY --chmod=755 apps/dev-workstation/fetch.sh /usr/local/bin/fetch
RUN mkdir -p "$OUT/bin"
WORKDIR /tmp

# --- Cluster, GitOps and infrastructure CLIs ---

FROM fetcher AS kubectl
# renovate: datasource=github-releases depName=kubernetes/kubernetes
ARG KUBECTL_VERSION=v1.37.2
RUN url="https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/$(dpkg --print-architecture)/kubectl" \
    && fetch "$url" "$OUT/bin/kubectl" "$url.sha256"

# Upstream publishes no checksum file. These hashes come from the krew index
# (plugins/browse-pvc.yaml), so a version bump fails here until they are updated.
# kubectl looks up `kubectl browse-pvc` as kubectl-browse_pvc.
FROM fetcher AS browse-pvc
# renovate: datasource=github-releases depName=clbx/kubectl-browse-pvc
ARG BROWSE_PVC_VERSION=v1.4.4
ARG BROWSE_PVC_SHA256_AMD64=d539e655e0cc93a03793e1d82db1c86e0073aa6ccc54fd03e0ec2fabf48adbe5
ARG BROWSE_PVC_SHA256_ARM64=9bbe163912a131638e2a219d8367148ef759d44e195fb81ad124c6d84b9f4deb
RUN case "$(dpkg --print-architecture)" in \
      amd64) asset=linux-x86_64; sum="$BROWSE_PVC_SHA256_AMD64" ;; \
      arm64) asset=linux-arm; sum="$BROWSE_PVC_SHA256_ARM64" ;; \
    esac \
    && fetch "https://github.com/clbx/kubectl-browse-pvc/releases/download/${BROWSE_PVC_VERSION}/kubectl-browse-pvc-${asset}.zip" a.zip "sha256:$sum" \
    && unzip -q a.zip kubectl-browse-pvc -d "$OUT/bin" \
    && ln -s kubectl-browse-pvc "$OUT/bin/kubectl-browse_pvc"

FROM fetcher AS helm
# renovate: datasource=github-releases depName=helm/helm
ARG HELM_VERSION=v4.3.1
RUN arch=$(dpkg --print-architecture) \
    && url="https://get.helm.sh/helm-${HELM_VERSION}-linux-${arch}.tar.gz" \
    && fetch "$url" a.tgz "$url.sha256sum" \
    && tar --no-same-owner -xzf a.tgz --strip-components=1 -C "$OUT/bin" "linux-${arch}/helm"

FROM fetcher AS helmfile
# renovate: datasource=github-releases depName=helmfile/helmfile
ARG HELMFILE_VERSION=v1.8.2
RUN base="https://github.com/helmfile/helmfile/releases/download/${HELMFILE_VERSION}" v="${HELMFILE_VERSION#v}" \
    && fetch "$base/helmfile_${v}_linux_$(dpkg --print-architecture).tar.gz" a.tgz "$base/helmfile_${v}_checksums.txt" \
    && tar --no-same-owner -xzf a.tgz -C "$OUT/bin" helmfile

FROM fetcher AS kustomize
# renovate: datasource=github-releases depName=kubernetes-sigs/kustomize versionTemplate=^kustomize/v(?<version>\d+\.\d+\.\d+)$
ARG KUSTOMIZE_VERSION=5.8.3
RUN base="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}" \
    && fetch "$base/kustomize_v${KUSTOMIZE_VERSION}_linux_$(dpkg --print-architecture).tar.gz" a.tgz "$base/checksums.txt" \
    && tar --no-same-owner -xzf a.tgz -C "$OUT/bin" kustomize

FROM fetcher AS argocd
# renovate: datasource=github-releases depName=argoproj/argo-cd
ARG ARGOCD_VERSION=v3.5.7
RUN base="https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}" \
    && fetch "$base/argocd-linux-$(dpkg --print-architecture)" "$OUT/bin/argocd" "$base/cli_checksums.txt"

FROM fetcher AS kubelogin
# renovate: datasource=github-releases depName=int128/kubelogin
ARG KUBELOGIN_VERSION=v1.36.4
RUN url="https://github.com/int128/kubelogin/releases/download/${KUBELOGIN_VERSION}/kubelogin_linux_$(dpkg --print-architecture).zip" \
    && fetch "$url" a.zip "$url.sha256" \
    && unzip -q a.zip kubelogin -d "$OUT/bin" \
    && ln -s kubelogin "$OUT/bin/kubectl-oidc_login"

FROM fetcher AS k9s
# renovate: datasource=github-releases depName=derailed/k9s
ARG K9S_VERSION=v0.51.0
RUN base="https://github.com/derailed/k9s/releases/download/${K9S_VERSION}" \
    && fetch "$base/k9s_Linux_$(dpkg --print-architecture).tar.gz" a.tgz "$base/checksums.sha256" \
    && tar --no-same-owner -xzf a.tgz -C "$OUT/bin" k9s

FROM fetcher AS stern
# renovate: datasource=github-releases depName=stern/stern
ARG STERN_VERSION=v1.35.0
RUN base="https://github.com/stern/stern/releases/download/${STERN_VERSION}" \
    && fetch "$base/stern_${STERN_VERSION#v}_linux_$(dpkg --print-architecture).tar.gz" a.tgz "$base/checksums.txt" \
    && tar --no-same-owner -xzf a.tgz -C "$OUT/bin" stern

# Upstream publishes no checksum file.
FROM fetcher AS egctl
# renovate: datasource=github-releases depName=envoyproxy/gateway
ARG EGCTL_VERSION=v1.9.3
RUN arch=$(dpkg --print-architecture) \
    && fetch "https://github.com/envoyproxy/gateway/releases/download/${EGCTL_VERSION}/egctl_${EGCTL_VERSION}_linux_${arch}.tar.gz" a.tgz \
    && tar --no-same-owner -xzf a.tgz --strip-components=3 -C "$OUT/bin" "bin/linux/${arch}/egctl"

# Follows TALOS_VERSION in home-ops, not upstream releases: `task talos:install`
# is skipped only on an exact match. See ci/check-version-parity.sh.
FROM fetcher AS talosctl
# renovate: datasource=custom.home-ops-talos depName=talosctl
ARG TALOS_VERSION=v1.14.4
RUN base="https://github.com/siderolabs/talos/releases/download/${TALOS_VERSION}" \
    && fetch "$base/talosctl-linux-$(dpkg --print-architecture)" "$OUT/bin/talosctl" "$base/sha256sum.txt"
RUN "$OUT/bin/talosctl" version --client --short | grep -qF "Talos ${TALOS_VERSION}"

# Follows CILIUM_VERSION in home-ops, for the same reason as talosctl.
FROM fetcher AS cilium
# renovate: datasource=custom.home-ops-cilium depName=cilium-cli
ARG CILIUM_VERSION=v0.20.1
RUN url="https://github.com/cilium/cilium-cli/releases/download/${CILIUM_VERSION}/cilium-linux-$(dpkg --print-architecture).tar.gz" \
    && fetch "$url" a.tgz "$url.sha256sum" \
    && tar --no-same-owner -xzf a.tgz -C "$OUT/bin" cilium
RUN "$OUT/bin/cilium" version --client | grep -qF "cilium-cli: ${CILIUM_VERSION}"

FROM fetcher AS terraform
# renovate: datasource=github-releases depName=hashicorp/terraform
ARG TERRAFORM_VERSION=1.17.1
RUN base="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}" \
    && fetch "$base/terraform_${TERRAFORM_VERSION}_linux_$(dpkg --print-architecture).zip" a.zip "$base/terraform_${TERRAFORM_VERSION}_SHA256SUMS" \
    && unzip -q a.zip terraform -d "$OUT/bin"

# Upstream publishes only .proof files, no checksum file.
FROM fetcher AS age
# renovate: datasource=github-releases depName=FiloSottile/age
ARG AGE_VERSION=v1.3.2
RUN fetch "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-$(dpkg --print-architecture).tar.gz" a.tgz \
    && tar --no-same-owner -xzf a.tgz --strip-components=1 -C "$OUT/bin" age/age age/age-keygen

# --- Secrets, AI and workspace CLIs ---

FROM fetcher AS bws
# renovate: datasource=github-releases depName=bitwarden/sdk-sm versionTemplate=^bws-v(?<version>\d+\.\d+\.\d+)$
ARG BWS_VERSION=2.0.0
RUN base="https://github.com/bitwarden/sdk-sm/releases/download/bws-v${BWS_VERSION}" \
    && fetch "$base/bws-$(uname -m)-unknown-linux-gnu-${BWS_VERSION}.zip" a.zip "$base/bws-sha256-checksums-${BWS_VERSION}.txt" \
    && unzip -q a.zip bws -d "$OUT/bin"

FROM fetcher AS coder
# renovate: datasource=github-releases depName=coder/coder
ARG CODER_VERSION=v2.38.0
RUN base="https://github.com/coder/coder/releases/download/${CODER_VERSION}" v="${CODER_VERSION#v}" \
    && fetch "$base/coder_${v}_linux_$(dpkg --print-architecture).tar.gz" a.tgz "$base/coder_${v}_checksums.txt" \
    && tar --no-same-owner -xzf a.tgz -C "$OUT/bin" ./coder

# The whole package is kept: `codex` finds codex-package.json, its helper
# binaries and codex-resources (bwrap) relative to its own real path, so it
# needs them beside it even though --version and --help run without them.
FROM fetcher AS codex
# renovate: datasource=github-releases depName=openai/codex versionTemplate=^rust-v(?<version>\d+\.\d+\.\d+)$
ARG CODEX_VERSION=0.166.0
RUN base="https://github.com/openai/codex/releases/download/rust-v${CODEX_VERSION}" \
    && fetch "$base/codex-package-$(uname -m)-unknown-linux-musl.tar.gz" a.tgz "$base/codex-package_SHA256SUMS" \
    && mkdir -p "$OUT/lib/codex" \
    && tar --no-same-owner -xzf a.tgz -C "$OUT/lib/codex" \
    && ln -s ../lib/codex/bin/codex "$OUT/bin/codex"

FROM fetcher AS chezmoi
# renovate: datasource=github-releases depName=twpayne/chezmoi
ARG CHEZMOI_VERSION=v2.74.0
RUN base="https://github.com/twpayne/chezmoi/releases/download/${CHEZMOI_VERSION}" v="${CHEZMOI_VERSION#v}" \
    && fetch "$base/chezmoi_${v}_linux_$(dpkg --print-architecture).tar.gz" a.tgz "$base/chezmoi_${v}_checksums.txt" \
    && tar --no-same-owner -xzf a.tgz -C "$OUT/bin" chezmoi

# Upstream publishes no checksum file.
FROM fetcher AS direnv
# renovate: datasource=github-releases depName=direnv/direnv
ARG DIRENV_VERSION=v2.38.2
RUN fetch "https://github.com/direnv/direnv/releases/download/${DIRENV_VERSION}/direnv.linux-$(dpkg --print-architecture)" "$OUT/bin/direnv"

FROM fetcher AS gh
# renovate: datasource=github-releases depName=cli/cli
ARG GH_VERSION=v2.103.3
RUN arch=$(dpkg --print-architecture) base="https://github.com/cli/cli/releases/download/${GH_VERSION}" v="${GH_VERSION#v}" \
    && fetch "$base/gh_${v}_linux_${arch}.tar.gz" a.tgz "$base/gh_${v}_checksums.txt" \
    && tar --no-same-owner -xzf a.tgz --strip-components=2 -C "$OUT/bin" "gh_${v}_linux_${arch}/bin/gh"

# --- Build, lint and docs tooling ---

FROM fetcher AS task
# renovate: datasource=github-releases depName=go-task/task
ARG TASK_VERSION=v3.54.0
RUN base="https://github.com/go-task/task/releases/download/${TASK_VERSION}" \
    && fetch "$base/task_linux_$(dpkg --print-architecture).tar.gz" a.tgz "$base/task_checksums.txt" \
    && tar --no-same-owner -xzf a.tgz -C "$OUT/bin" task

FROM fetcher AS gitleaks
# renovate: datasource=github-releases depName=gitleaks/gitleaks
ARG GITLEAKS_VERSION=v8.30.1
RUN case "$(dpkg --print-architecture)" in amd64) arch=x64 ;; arm64) arch=arm64 ;; esac \
    && base="https://github.com/gitleaks/gitleaks/releases/download/${GITLEAKS_VERSION}" v="${GITLEAKS_VERSION#v}" \
    && fetch "$base/gitleaks_${v}_linux_${arch}.tar.gz" a.tgz "$base/gitleaks_${v}_checksums.txt" \
    && tar --no-same-owner -xzf a.tgz -C "$OUT/bin" gitleaks

# Upstream publishes no checksum file.
FROM fetcher AS shellcheck
# renovate: datasource=github-releases depName=koalaman/shellcheck
ARG SHELLCHECK_VERSION=v0.11.0
RUN fetch "https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK_VERSION}/shellcheck-${SHELLCHECK_VERSION}.linux.$(uname -m).tar.gz" a.tgz \
    && tar --no-same-owner -xzf a.tgz --strip-components=1 -C "$OUT/bin" "shellcheck-${SHELLCHECK_VERSION}/shellcheck"

# Upstream publishes no checksum file.
FROM fetcher AS cue
# renovate: datasource=github-releases depName=cue-lang/cue
ARG CUE_VERSION=v0.17.1
RUN fetch "https://github.com/cue-lang/cue/releases/download/${CUE_VERSION}/cue_${CUE_VERSION}_linux_$(dpkg --print-architecture).tar.gz" a.tgz \
    && tar --no-same-owner -xzf a.tgz -C "$OUT/bin" cue

# Same goss as CI and Taskfile.yml. Releases from v0.4 on name their assets differently.
FROM fetcher AS goss
# renovate: datasource=github-releases depName=goss-org/goss
ARG GOSS_VERSION=v0.3.21
RUN base="https://github.com/goss-org/goss/releases/download/${GOSS_VERSION}" arch=$(dpkg --print-architecture) \
    && fetch "$base/goss-linux-${arch}" "$OUT/bin/goss" "$base/goss-linux-${arch}.sha256" \
    && fetch "$base/dgoss" "$OUT/bin/dgoss" "$base/dgoss.sha256"

FROM fetcher AS jq
# renovate: datasource=github-releases depName=jqlang/jq versionTemplate=^jq-(?<version>\d+\.\d+\.\d+)$
ARG JQ_VERSION=1.8.2
RUN base="https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}" \
    && fetch "$base/jq-linux-$(dpkg --print-architecture)" "$OUT/bin/jq" "$base/sha256sum.txt"

# `checksums` has one column per hash algorithm; checksums_hashes_order names them.
FROM fetcher AS yq
# renovate: datasource=github-releases depName=mikefarah/yq
ARG YQ_VERSION=v4.54.1
RUN base="https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}" asset="yq_linux_$(dpkg --print-architecture)" \
    && fetch "$base/checksums" sums \
    && fetch "$base/checksums_hashes_order" order \
    && column=$(($(grep -nx 'SHA-256' order | cut -d: -f1) + 1)) \
    && fetch "$base/$asset" "$OUT/bin/yq" "sha256:$(awk -v name="$asset" -v column="$column" '$1 == name { print $column }' sums)"

FROM fetcher AS node
# renovate: datasource=node-version depName=node versioning=node
ARG NODE_VERSION=26.13.0
RUN case "$(dpkg --print-architecture)" in amd64) arch=x64 ;; arm64) arch=arm64 ;; esac \
    && base="https://nodejs.org/dist/v${NODE_VERSION}" \
    && fetch "$base/node-v${NODE_VERSION}-linux-${arch}.tar.gz" a.tgz "$base/SHASUMS256.txt" \
    && tar --no-same-owner -xzf a.tgz --strip-components=1 -C "$OUT" \
      --exclude='*/include' --exclude='*/share' --exclude='*/CHANGELOG.md' --exclude='*/README.md' --exclude='*/LICENSE'

FROM fetcher AS go
# renovate: datasource=golang-version depName=go
ARG GO_VERSION=1.27.3
RUN url="https://dl.google.com/go/go${GO_VERSION}.linux-$(dpkg --print-architecture).tar.gz" \
    && fetch "$url" a.tgz "$url.sha256" \
    && tar --no-same-owner -xzf a.tgz -C "$OUT" \
    && rm -rf "$OUT/go/api" "$OUT/go/doc" "$OUT/go/test" \
    && ln -s ../go/bin/go ../go/bin/gofmt "$OUT/bin/"

# Versions and hashes live in python/requirements.txt, regenerated by Renovate
# from python/requirements.in. --only-binary keeps this image free of a compiler.
FROM os AS python-tools
COPY apps/dev-workstation/python/requirements.txt /opt/dev-tools/requirements.txt
RUN python3 -m venv /opt/dev-tools \
    && /opt/dev-tools/bin/pip install --no-cache-dir --require-hashes --only-binary :all: -r /opt/dev-tools/requirements.txt

# Versions and integrity hashes live in npm/package-lock.json. The postinstall of
# Claude Code moves its binary into place, so the platform package is redundant.
FROM os AS npm-tools
COPY --link --from=node /out/ /usr/local/
COPY apps/dev-workstation/npm/package.json apps/dev-workstation/npm/package-lock.json /usr/local/lib/npm-tools/
WORKDIR /usr/local/lib/npm-tools
RUN npm ci --omit=dev --no-audit --no-fund \
    && rm -rf node_modules/@anthropic-ai/claude-code-linux-*

FROM os
ARG VERSION
ARG CHANNEL

LABEL devcontainer.metadata='[{"remoteUser":"vscode","containerUser":"vscode"}]'

# /usr/local is not writable by vscode, so Claude Code could not update itself.
ENV DISABLE_AUTOUPDATER=1

COPY --link --from=kubectl /out/ /usr/local/
COPY --link --from=browse-pvc /out/ /usr/local/
COPY --link --from=helm /out/ /usr/local/
COPY --link --from=helmfile /out/ /usr/local/
COPY --link --from=kustomize /out/ /usr/local/
COPY --link --from=argocd /out/ /usr/local/
COPY --link --from=kubelogin /out/ /usr/local/
COPY --link --from=k9s /out/ /usr/local/
COPY --link --from=stern /out/ /usr/local/
COPY --link --from=egctl /out/ /usr/local/
COPY --link --from=talosctl /out/ /usr/local/
COPY --link --from=cilium /out/ /usr/local/
COPY --link --from=terraform /out/ /usr/local/
COPY --link --from=age /out/ /usr/local/
COPY --link --from=bws /out/ /usr/local/
COPY --link --from=coder /out/ /usr/local/
COPY --link --from=codex /out/ /usr/local/
COPY --link --from=chezmoi /out/ /usr/local/
COPY --link --from=direnv /out/ /usr/local/
COPY --link --from=gh /out/ /usr/local/
COPY --link --from=task /out/ /usr/local/
COPY --link --from=gitleaks /out/ /usr/local/
COPY --link --from=shellcheck /out/ /usr/local/
COPY --link --from=cue /out/ /usr/local/
COPY --link --from=goss /out/ /usr/local/
COPY --link --from=jq /out/ /usr/local/
COPY --link --from=yq /out/ /usr/local/
COPY --link --from=node /out/ /usr/local/
COPY --link --from=go /out/ /usr/local/
COPY --link --from=python-tools /opt/dev-tools /opt/dev-tools
COPY --link --from=npm-tools /usr/local/lib/npm-tools /usr/local/lib/npm-tools

# Symlinks instead of PATH entries: /etc/profile resets PATH in login shells.
# /etc/skel is the seed for an empty home volume, so it must be final before useradd.
# The base image gives UID 1000 to a default ubuntu user.
RUN ln -s /opt/dev-tools/bin/pre-commit /opt/dev-tools/bin/yamllint /opt/dev-tools/bin/mkdocs /usr/local/bin/ \
    && ln -s ../lib/npm-tools/node_modules/.bin/claude ../lib/npm-tools/node_modules/.bin/prettier ../lib/npm-tools/node_modules/.bin/markdownlint /usr/local/bin/ \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd \
    && echo 'eval "$(direnv hook bash)"' >> /etc/bash.bashrc \
    && git config --system init.defaultBranch main \
    && git config --system pull.rebase true \
    && userdel --remove ubuntu \
    && useradd --create-home --uid 1000 --shell /bin/bash vscode \
    && mkdir /workspaces \
    && chown vscode:vscode /workspaces

# Numeric, so a pod with runAsNonRoot can verify it.
USER 1000:1000
WORKDIR /home/vscode
