FROM mcr.microsoft.com/devcontainers/universal:2@sha256:dca6a985ffbbc74007a13b6f56ac0fbbc5febae081350b66e865a5549338134b
USER codespace

# [Optional] Uncomment this section to install additional OS packages.
RUN sudo apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && sudo apt-get -y install gnupg2 putty-tools build-essential --no-install-recommends \
    && sudo apt-get clean -y && sudo rm -rf /var/lib/apt/lists/*

# Pre install brew packages
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" \
    && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" >> /home/codespace/.profile \
    && brew analytics off

ENV PATH=/home/linuxbrew/.linuxbrew/bin:$PATH
RUN brew install \
    go-task/tap/go-task \
    gcc \
    cue-lang/tap/cue
