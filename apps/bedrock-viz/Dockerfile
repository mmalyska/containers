FROM ghcr.io/onedr0p/alpine:rolling@sha256:6d6a07c8c747e58846bb3125d4e14bb64cdea6287faef647ba072740892517f1 as builder

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

FROM ghcr.io/onedr0p/alpine:rolling@sha256:6d6a07c8c747e58846bb3125d4e14bb64cdea6287faef647ba072740892517f1



RUN \
    apk add --no-cache \
        boost \
        libpng \
        zlib

COPY --from=builder /usr/local/share/bedrock-viz /usr/local/share/bedrock-viz
COPY --from=builder /usr/local/bin/bedrock-viz /usr/local/bin/
COPY ./apps/bedrock-viz/entrypoint.sh /entrypoint.sh
RUN \
    chown -R kah:kah /entrypoint.sh \
    && chmod -R 775 /entrypoint.sh

USER kah
ENTRYPOINT ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/bedrock-viz/bedrock-viz"
