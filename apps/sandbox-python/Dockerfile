FROM ghcr.io/mmalyska/sandbox-base:rolling@sha256:7ef924ccf746ac038612eed957aa90ddf44bd0752edf32e43ad214fafdf44db8

ARG VERSION
ARG CHANNEL

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-venv \
    python3-pip \
    python3.12-dev \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh \
    && uv pip install --system --break-system-packages \
       jupyter notebook pandas numpy scipy scikit-learn requests httpx

USER coder
