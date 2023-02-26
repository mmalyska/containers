FROM mcr.microsoft.com/devcontainers/universal:2
USER codespace

# [Optional] Uncomment this section to install additional OS packages.
RUN sudo apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && sudo apt-get -y install gnupg2 putty-tools --no-install-recommends \
    && sudo apt-get clean -y && sudo rm -rf /var/lib/apt/lists/*
