FROM ghcr.io/mmalyska/sandbox-base:rolling@sha256:b985bcfe1c0c4e2f2a6d702d7581a342eb1182063030c75d2181b5dfd7be4d4e

ARG VERSION
ARG CHANNEL

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    libicu74 \
    libgssapi-krb5-2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    && /tmp/dotnet-install.sh --channel 9.0 --install-dir /usr/local/dotnet \
    && /tmp/dotnet-install.sh --channel 10.0 --install-dir /usr/local/dotnet \
    && rm /tmp/dotnet-install.sh

ENV DOTNET_ROOT=/usr/local/dotnet
ENV PATH="$PATH:/usr/local/dotnet"

USER coder
ENV PATH="$PATH:/home/coder/.dotnet/tools"
RUN dotnet tool install -g dotnet-ef \
    && dotnet tool install -g csharpier
