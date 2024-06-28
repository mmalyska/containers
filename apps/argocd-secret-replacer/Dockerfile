FROM public.ecr.aws/docker/library/alpine:latest@sha256:b89d9c93e9ed3597455c90a0b88a8bbb5cb7188438f70953fede212a0c4394e0

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

# renovate: datasource=github-releases depName=helm/helm
ARG HELM_VERSION=v3.15.2
# renovate: datasource=github-releases depName=kubernetes-sigs/kustomize
ARG KUSTOMIZE_VERSION=kustomize/v4.5.7
# renovate: datasource=github-releases depName=getsops/sops
ARG SOPS_VERSION=v3.9.0

RUN case "${TARGETPLATFORM}" in \
    'linux/amd64') ARCH=amd64; ;; \
    'linux/arm64') ARCH=arm64; ;; \
    *) echo "un-supported arch, exit ..."; exit 1; ;; \
    esac && \
    echo "export ARCH=$ARCH" > /envfile && \
    cat /envfile

# install dotnet dependencies https://learn.microsoft.com/en-us/dotnet/core/install/linux-alpine#dependencies
RUN apk add --no-cache \
    icu-libs krb5-libs libgcc libintl libssl3 libstdc++ zlib

# add helm
RUN . /envfile && echo $ARCH && \
    apk add --update --no-cache curl ca-certificates bash git && \
    curl -sL https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCH}.tar.gz | tar -xvz && \
    mv linux-${ARCH}/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-${ARCH}

# Install jq
RUN apk add --update --no-cache jq yq

# Install kustomize
RUN . /envfile && \
    curl -sLO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION#kustomize/}/kustomize_${KUSTOMIZE_VERSION#kustomize/}_linux_${ARCH}.tar.gz && \
    tar xvzf kustomize_${KUSTOMIZE_VERSION#kustomize/}_linux_${ARCH}.tar.gz && \
    mv kustomize /usr/bin/kustomize && \
    chmod +x /usr/bin/kustomize && \
    rm -rf kustomize_${KUSTOMIZE_VERSION#kustomize/}_linux_${ARCH}.tar.gz

# Install for envsubst
RUN apk add --update --no-cache gettext

# Install sops
RUN . /envfile && \
    curl -sLO https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.${ARCH} && \
    mv sops-${SOPS_VERSION}.linux.${ARCH} /usr/bin/sops && \
    chmod +x /usr/bin/sops

# Install sops-replacer
RUN . /envfile && \
    case "${ARCH}" in \
    'amd64') curl -sL https://github.com/mmalyska/argocd-secret-replacer/releases/download/v${VERSION}/secret-replacer-v${VERSION}-linux-musl-x64.tar.gz | tar -xvz; ;; \
    'arm64') curl -sL https://github.com/mmalyska/argocd-secret-replacer/releases/download/v${VERSION}/secret-replacer-v${VERSION}-linux-musl-arm64.tar.gz | tar -xvz; ;; \
    esac && \
    mv argocd-secret-replacer /usr/bin/argocd-secret-replacer && \
    chmod +x /usr/bin/argocd-secret-replacer

WORKDIR /apps
