FROM public.ecr.aws/docker/library/alpine:3.21@sha256:21dc6063fd678b478f57c0e13f47560d0ea4eeba26dfc947b2a4f81f686b9f45
ARG VERSION

# install dotnet dependencies https://learn.microsoft.com/en-us/dotnet/core/install/linux-alpine#dependencies
RUN apk add --no-cache \
    icu-libs krb5-libs libgcc libintl libssl3 libstdc++ zlib

# install server deps
RUN apk add --no-cache \
    tar gzip curl dotnet7-runtime zstd sqlite-libs gcompat

RUN mkdir /server
WORKDIR /server

RUN curl -sL https://cdn.vintagestory.at/gamefiles/stable/vs_server_linux-x64_${VERSION}.tar.gz | tar -xvzf - && \
    chmod +x server.sh

COPY ./apps/vintagestory/entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
