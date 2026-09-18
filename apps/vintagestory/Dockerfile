FROM public.ecr.aws/docker/library/alpine:3.24@sha256:5b02b42e375f7426f8d65c3af331ca05d9878f9989230354504e0b9dfd431f60
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
