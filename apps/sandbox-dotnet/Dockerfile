FROM ghcr.io/mmalyska/sandbox-base:rolling@sha256:3cf709cc04cd8a429e5082c19b4279f7ccff9549d84bf97688b67962aca08825

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
