FROM acore/ac-wotlk-worldserver:master@sha256:cb1a0999a991808de672ba7b5a17fa2a7bebda2e0a1edaaba843b5c83dfad25a AS builder

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libtool cmake-data cmake clang \
    git curl unzip openssl \
    default-mysql-client default-libmysqlclient-dev libmysql++-dev \
    libboost-all-dev libssl-dev \
    libreadline-dev zlib1g-dev libbz2-dev libncurses5-dev liblzma-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /azerothcore-src

RUN git clone --depth 1 https://github.com/azerothcore/azerothcore-wotlk . \
 && git clone --depth 1 https://github.com/azerothcore/mod-solocraft modules/mod-solocraft \
 && git clone --depth 1 https://github.com/azerothcore/mod-ah-bot modules/mod-ah-bot \
 && git clone --depth 1 https://github.com/azerothcore/mod-transmog modules/mod-transmog \
 && git clone --depth 1 https://github.com/azerothcore/mod-solo-lfg modules/mod-solo-lfg

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

FROM acore/ac-wotlk-worldserver:master@sha256:cb1a0999a991808de672ba7b5a17fa2a7bebda2e0a1edaaba843b5c83dfad25a
COPY --from=builder /azerothcore/env/dist/bin/worldserver /azerothcore/env/dist/bin/worldserver
COPY --from=builder /azerothcore/env/dist/etc/modules/ /azerothcore/env/ref/etc/modules/
