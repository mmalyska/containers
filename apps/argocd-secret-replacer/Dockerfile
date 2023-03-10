FROM public.ecr.aws/docker/library/alpine:latest@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ARG HELM_VERSION=3.2.1
ARG KUSTOMIZE_VERSION=v3.8.1
ARG SOPS_VERSION=v3.7.3
ARG REPLACER_VERSION=v0.1.1

RUN case "${TARGETPLATFORM}" in \
    'linux/amd64') ARCH=amd64; ;; \
    'linux/arm64') ARCH=arm64; ;; \
    *) echo "un-supported arch, exit ..."; exit 1; ;; \
    esac && \
    echo "export ARCH=$ARCH" > /envfile && \
    cat /envfile


# add helm
RUN . /envfile && echo $ARCH && \
    apk add --update --no-cache curl ca-certificates bash git && \
    curl -sL https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz | tar -xvz && \
    mv linux-${ARCH}/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-${ARCH}

# Install kustomize
RUN . /envfile && \
    curl -sLO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz && \
    tar xvzf kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz && \
    mv kustomize /usr/bin/kustomize && \
    chmod +x /usr/bin/kustomize && \
    rm -rf kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz

# Install jq
RUN apk add --update --no-cache jq yq

# Install for envsubst
RUN apk add --update --no-cache gettext

# Install sops
RUN . /envfile && \
    curl -sLO https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.${ARCH} && \
    mv sops-${SOPS_VERSION}.linux.${ARCH} /usr/bin/sops && \
    chmod +x /usr/bin/sops

# Install sops-replacer
RUN . /envfile && \
    case "${ARCH}" in \
    'amd64') curl -sL https://github.com/mmalyska/argocd-secret-replacer/releases/download/${REPLACER_VERSION}/secret-replacer-${REPLACER_VERSION}-linux-musl-x64.tar.gz | tar -xvz; ;; \
    'arm64') curl -sL https://github.com/mmalyska/argocd-secret-replacer/releases/download/${REPLACER_VERSION}/secret-replacer-${REPLACER_VERSION}-linux-musl-arm64.tar.gz | tar -xvz; ;; \
    esac && \
    mv argocd-secret-replacer /usr/bin/argocd-secret-replacer && \
    chmod +x /usr/bin/argocd-secret-replacer

WORKDIR /apps
