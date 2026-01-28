FROM public.ecr.aws/docker/library/alpine:3.23@sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659
ARG VERSION

# install dotnet dependencies https://learn.microsoft.com/en-us/dotnet/core/install/linux-alpine#dependencies
RUN apk add --no-cache \
    icu-libs krb5-libs libgcc libintl libssl3 libstdc++ zlib

# install server deps
RUN apk add --no-cache \
    tar gzip curl dotnet8-runtime zstd sqlite-libs gcompat

RUN mkdir /server
WORKDIR /server

RUN curl -sL https://cdn.vintagestory.at/gamefiles/stable/vs_server_linux-x64_${VERSION}.tar.gz | tar -xvzf - && \
    chmod +x server.sh && \
    cp /usr/lib/libsqlite3.so.0 /server/Lib/libe_sqlite3.so

COPY ./apps/vintagestory/entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
