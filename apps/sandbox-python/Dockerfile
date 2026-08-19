FROM ghcr.io/mmalyska/sandbox-base:rolling@sha256:5bb1c58839cf02ae723f1f122648b3a0d61e20a3a94cbf100e3412230a690baf

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
