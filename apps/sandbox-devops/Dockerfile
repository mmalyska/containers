FROM ghcr.io/mmalyska/sandbox-base:rolling@sha256:185dd31faf26abd9b55c398977c55432ca55205f906966d3667276d3a5e1f65e

ARG VERSION
ARG CHANNEL

USER root

# renovate: datasource=github-releases depName=kubernetes/kubernetes
ARG KUBECTL_VERSION=v1.36.2
# renovate: datasource=github-releases depName=helm/helm
ARG HELM_VERSION=v4.2.2
# renovate: datasource=github-releases depName=siderolabs/talos
ARG TALOSCTL_VERSION=v1.13.6
# renovate: datasource=github-releases depName=hashicorp/terraform
ARG TERRAFORM_VERSION=1.15.8
# renovate: datasource=github-releases depName=derailed/k9s
ARG K9S_VERSION=v0.51.0

RUN curl -fsSL https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
      -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl \
    && curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | \
      DESIRED_VERSION=${HELM_VERSION} bash \
    && curl -fsSL https://github.com/siderolabs/talos/releases/download/${TALOSCTL_VERSION}/talosctl-linux-amd64 \
      -o /usr/local/bin/talosctl && chmod +x /usr/local/bin/talosctl

RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
      -o /tmp/tf.zip && unzip /tmp/tf.zip -d /usr/local/bin && rm /tmp/tf.zip

RUN curl -fsSL https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz \
      | tar xz -C /usr/local/bin k9s

# renovate: datasource=github-releases depName=FiloSottile/age
ARG AGE_VERSION=v1.3.1
RUN curl -fsSL https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-amd64.tar.gz \
      | tar xz -C /tmp && mv /tmp/age/age /usr/local/bin/ && mv /tmp/age/age-keygen /usr/local/bin/

USER coder
