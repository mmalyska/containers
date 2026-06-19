FROM ghcr.io/mmalyska/sandbox-base:rolling@sha256:d0f1604a4dcd71ed20cb3bb97637a093a6328719740d2d9603c1e31adb707a2d

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
