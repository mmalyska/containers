FROM ghcr.io/mmalyska/sandbox-base:rolling@sha256:5c7683152757cccd90c6102f910219d2973e4fc124b0fd8c2049d13cf50e10f0

ARG VERSION
ARG CHANNEL

USER root

# renovate: datasource=node-version depName=node
ARG NODE_VERSION=22
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && corepack enable pnpm

USER coder
ENV PNPM_HOME="/home/coder/.local/share/pnpm"
ENV PATH="$PNPM_HOME/bin:$PNPM_HOME:$PATH"
RUN mkdir -p "$PNPM_HOME/bin" \
    && pnpm add -g expo-cli @expo/cli eas-cli
