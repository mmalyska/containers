FROM ghcr.io/onedr0p/alpine:rolling@sha256:dd504f02473c176a0e68e4550ccaf6f6c0f14e9f64c08a59877f9c6153bf48a9 as builder

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

RUN \
    apk add --no-cache \
        ${EXTRA_PACKAGES} \
        alpine-sdk \
        cmake \
        g++ \
        gcc \
        git \
        boost-dev \
        libpng-dev \
        zlib-dev

WORKDIR /tmp/bedrock-viz
RUN \
    if [ -n "${VERSION}" ]; \
    then \
        git clone --recursive --depth 1 -b "v${VERSION}" https://github.com/bedrock-viz/bedrock-viz.git .; \
    else \
        git clone --recursive --depth 1 https://github.com/bedrock-viz/bedrock-viz.git .; \
    fi \
    && git apply -p0 patches/leveldb-1.22.patch \
    && git apply -p0 patches/pugixml-disable-install.patch
RUN \
    mkdir -p build && cd build && \
    cmake .. && \
    make && \
    make install

FROM ghcr.io/onedr0p/alpine:rolling@sha256:dd504f02473c176a0e68e4550ccaf6f6c0f14e9f64c08a59877f9c6153bf48a9

ENV BEDROCKVIZ__OPTION="--html-all"

RUN \
    apk add --no-cache \
        boost \
        libpng \
        zlib

COPY --from=builder --chown=kah:kah /usr/local/share/bedrock-viz /usr/local/share/bedrock-viz
COPY --from=builder /usr/local/bin/bedrock-viz /usr/local/bin/
COPY ./apps/bedrock-viz/entrypoint.sh /entrypoint.sh

RUN \
    mkdir -p /world \
    && chown -R kah:kah /world \
    && chmod -R 775 /world \
    && mkdir -p /out \
    && chown -R kah:kah /out \
    && chmod -R 775 /out

RUN \
    chown -R kah:kah /entrypoint.sh \
    && chmod -R 775 /entrypoint.sh

CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/bedrock-viz/bedrock-viz"
