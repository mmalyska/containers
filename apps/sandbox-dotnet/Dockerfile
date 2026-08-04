FROM ghcr.io/mmalyska/sandbox-base:rolling@sha256:9d0ec39b5efd7bcff27ae286cbb3ed9bf08663f1caea0772b0f210241a2aa8c6

ARG VERSION
ARG CHANNEL

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && add-apt-repository ppa:dotnet/backports \
    && apt-get update && apt-get install -y --no-install-recommends \
    dotnet-sdk-9.0 \
    dotnet-sdk-10.0 \
    && apt-get remove --autoremove -y software-properties-common \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

USER coder
ENV PATH="$PATH:/home/coder/.dotnet/tools"
RUN dotnet tool install -g dotnet-ef \
    && dotnet tool install -g csharpier
