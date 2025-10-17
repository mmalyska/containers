FROM mcr.microsoft.com/devcontainers/universal:4@sha256:8e7d06fef78a7fcb5867cd6ed78abcc13743f5cc3712517d0c81a26a87d9de4e
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
