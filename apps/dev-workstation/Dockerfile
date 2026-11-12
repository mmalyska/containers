# apt provides the OS and mise.toml lists every tool. Nothing goes under
# /home/vscode: the workspace mounts a volume over the home directory.
FROM ubuntu:24.04@sha256:2198e4c65076e9cb0b3d695219df667c0e3b0072da64ca3c2648aca17dcecaf5
ARG VERSION
ARG CHANNEL
# renovate: datasource=github-releases depName=jdx/mise
ARG MISE_VERSION=v2026.11.5

LABEL devcontainer.metadata='[{"remoteUser":"vscode","containerUser":"vscode","mounts":["source=dev-workstation-cache,target=/cache,type=volume"]}]'

# /opt/mise is not writable by vscode, so Claude Code could not update itself.
# mise reads image tools from there and installs new ones into the home volume.
ENV MISE_SHARED_INSTALL_DIRS=/opt/mise/installs DISABLE_AUTOUPDATER=1

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
      openssh-server \
      ripgrep \
      unzip \
      vim \
    && rm -f /etc/ssh/ssh_host_* \
    && locale-gen en_US.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

COPY apps/dev-workstation/mise.toml /etc/mise/config.toml

RUN case "$(dpkg --print-architecture)" in amd64) arch=x64 ;; arm64) arch=arm64 ;; esac \
    && asset="mise-${MISE_VERSION}-linux-${arch}" base="https://github.com/jdx/mise/releases/download/${MISE_VERSION}" \
    && curl -fsSL --retry 5 "$base/$asset" -o /usr/local/bin/mise \
    && echo "$(curl -fsSL --retry 5 "$base/SHASUMS256.txt" | grep "$asset\$" | cut -d' ' -f1)  /usr/local/bin/mise" | sha256sum --check --quiet \
    && chmod 755 /usr/local/bin/mise \
    && MISE_DATA_DIR=/opt/mise mise install --yes \
    && rm -rf /opt/mise/downloads /root/.cache /root/.local

# Set after the install, which would otherwise leave its downloads in the image. Rebuildable
# caches stay off the backed-up volumes. Only /cache itself can be relied on: a mount there
# starts empty, and Terraform fails if its plugin cache directory is missing.
ENV XDG_CACHE_HOME=/cache GOMODCACHE=/cache/go/mod npm_config_cache=/cache/npm TF_PLUGIN_CACHE_DIR=/cache UV_LINK_MODE=copy

# Symlinks instead of PATH entries: /etc/profile resets PATH in login shells.
# /etc/skel is the seed for an empty home volume, so it must be final before useradd.
# The base image gives UID 1000 to a default ubuntu user.
RUN ln -s /opt/mise/shims/* /usr/local/bin/ \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd \
    && printf '%s\n' 'eval "$(mise activate bash)"' 'eval "$(direnv hook bash)"' >> /etc/bash.bashrc \
    && git config --system init.defaultBranch main \
    && git config --system pull.rebase true \
    && userdel --remove ubuntu \
    && useradd --create-home --uid 1000 --shell /bin/bash vscode \
    && mkdir /workspaces /cache \
    && chown vscode:vscode /workspaces /cache

# Numeric, so a pod with runAsNonRoot can verify it.
USER 1000:1000
WORKDIR /workspaces
