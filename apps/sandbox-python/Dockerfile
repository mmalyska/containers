FROM ghcr.io/mmalyska/sandbox-base:rolling@sha256:d0f1604a4dcd71ed20cb3bb97637a093a6328719740d2d9603c1e31adb707a2d

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
