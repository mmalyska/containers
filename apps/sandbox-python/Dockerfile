FROM ghcr.io/mmalyska/sandbox-base:rolling@sha256:155b230596763f2b6aae6c530dd74d6a61c718219b1ce04314a4aaa8bf4cb1d7

ARG VERSION
ARG CHANNEL

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-venv \
    python3-pip \
    python3-dev \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh \
    && uv pip install --system --break-system-packages \
       jupyter notebook pandas numpy scipy scikit-learn requests httpx

USER coder
