FROM acore/ac-wotlk-dev:master AS builder

WORKDIR /azerothcore-src

RUN git clone --depth 1 https://github.com/azerothcore/azerothcore-wotlk . \
 && git clone --depth 1 https://github.com/azerothcore/mod-solocraft modules/mod-solocraft \
 && git clone --depth 1 https://github.com/azerothcore/mod-ah-bot modules/mod-ah-bot \
 && git clone --depth 1 https://github.com/ZhengPeiRu21/mod-individual-progression modules/mod-individual-progression

RUN cmake -B cmake-build \
      -DCMAKE_INSTALL_PREFIX=/azerothcore/env/dist \
      -DAPPS_BUILD=world-only \
      -DTOOLS_BUILD=none \
      -DSCRIPTS=static \
      -DMODULES=static \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_CXX_COMPILER=clang++ \
      -DCMAKE_C_COMPILER=clang \
 && cmake --build cmake-build --target install -j$(nproc)

FROM acore/ac-wotlk-worldserver:master
COPY --from=builder /azerothcore/env/dist/bin/worldserver /azerothcore/env/dist/bin/worldserver
COPY --from=builder /azerothcore/env/dist/etc/modules/ /azerothcore/env/ref/etc/modules/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libboost_*.so.1.83.0 /usr/lib/x86_64-linux-gnu/
