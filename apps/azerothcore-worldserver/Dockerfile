FROM acore/ac-wotlk-worldserver:master@sha256:82122449b5e931badcf55cc547bab9335937503c98598efc04c1da2dd1141947 AS builder

ARG VERSION

# renovate: datasource=git-refs depName=https://github.com/azerothcore/mod-solocraft
ARG MOD_SOLOCRAFT_SHA=c3fb0b92b4372a9541f92cb4595e1ab08223e977
# renovate: datasource=git-refs depName=https://github.com/azerothcore/mod-ah-bot
ARG MOD_AHBOT_SHA=a680cc1c98290713e9b3d3289544af78e5186dc1
# renovate: datasource=git-refs depName=https://github.com/azerothcore/mod-transmog
ARG MOD_TRANSMOG_SHA=33ac64b2c305eb1b6fbc97310a7ecbc30c2ba4ef
# renovate: datasource=git-refs depName=https://github.com/azerothcore/mod-solo-lfg
ARG MOD_SOLOLFG_SHA=3821fe1d108ade8d2b7ad6611e41154e05864c65

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libtool cmake-data cmake clang \
    git curl unzip openssl \
    default-mysql-client default-libmysqlclient-dev libmysql++-dev \
    libboost-all-dev libssl-dev \
    libreadline-dev zlib1g-dev libbz2-dev libncurses5-dev liblzma-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /azerothcore-src

# Main repo version injected via VERSION build arg (set by ci/latest.sh).
# Module SHAs managed via ARG above — updated by Renovate.
RUN git init . \
 && git remote add origin https://github.com/azerothcore/azerothcore-wotlk \
 && git fetch --depth 1 origin ${VERSION} \
 && git checkout FETCH_HEAD \
 && git init modules/mod-solocraft \
 && git -C modules/mod-solocraft remote add origin https://github.com/azerothcore/mod-solocraft \
 && git -C modules/mod-solocraft fetch --depth 1 origin ${MOD_SOLOCRAFT_SHA} \
 && git -C modules/mod-solocraft checkout FETCH_HEAD \
 && git init modules/mod-ah-bot \
 && git -C modules/mod-ah-bot remote add origin https://github.com/azerothcore/mod-ah-bot \
 && git -C modules/mod-ah-bot fetch --depth 1 origin ${MOD_AHBOT_SHA} \
 && git -C modules/mod-ah-bot checkout FETCH_HEAD \
 && git init modules/mod-transmog \
 && git -C modules/mod-transmog remote add origin https://github.com/azerothcore/mod-transmog \
 && git -C modules/mod-transmog fetch --depth 1 origin ${MOD_TRANSMOG_SHA} \
 && git -C modules/mod-transmog checkout FETCH_HEAD \
 && git init modules/mod-solo-lfg \
 && git -C modules/mod-solo-lfg remote add origin https://github.com/azerothcore/mod-solo-lfg \
 && git -C modules/mod-solo-lfg fetch --depth 1 origin ${MOD_SOLOLFG_SHA} \
 && git -C modules/mod-solo-lfg checkout FETCH_HEAD

RUN cmake -B cmake-build \
      -DCMAKE_INSTALL_PREFIX=/azerothcore/env/dist \
      -DAPPS_BUILD=world-only \
      -DTOOLS_BUILD=none \
      -DSCRIPTS=static \
      -DMODULES=static \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_CXX_COMPILER=clang++ \
      -DCMAKE_C_COMPILER=clang \
      -DBoost_USE_STATIC_LIBS=ON \
 && cmake --build cmake-build --target install -j$(nproc)

RUN for f in /azerothcore/env/dist/etc/modules/*.conf.dist; do cp "$f" "${f%.dist}"; done

FROM acore/ac-wotlk-worldserver:master@sha256:82122449b5e931badcf55cc547bab9335937503c98598efc04c1da2dd1141947

# Add runtime deps introduced by the Ubuntu 22.04 → 24.04 upgrade in the base image.
# Mirrors what upstream added in azerothcore-wotlk PR #24459.
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    libicu74 libncurses5-dev \
 && rm -rf /var/lib/apt/lists/*
USER acore

COPY --from=builder /azerothcore/env/dist/bin/worldserver /azerothcore/env/dist/bin/worldserver
COPY --from=builder /azerothcore/env/dist/etc/modules/ /azerothcore/env/ref/etc/modules/
