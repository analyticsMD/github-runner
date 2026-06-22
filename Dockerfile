FROM ghcr.io/actions/actions-runner:latest

# ──────────────────────────────────────────────────────────────────────────────
# Tool versions
# ──────────────────────────────────────────────────────────────────────────────
ARG ATMOS_VERSION=1.221.1
ARG TERRAFORM_VERSION=1.9.8
ARG TFCMT_VERSION=4.14.5
ARG TERRAFORM_DOCS_VERSION=0.18.0
ARG INFRACOST_VERSION=0.10.40
ARG HELM_VERSION=3.14.3
ARG HELMFILE_VERSION=1.2.3
ARG KUBECTL_VERSION=1.29.4
ARG HELM_DIFF_VERSION=3.12.2

# ──────────────────────────────────────────────────────────────────────────────
# OS packages
# ──────────────────────────────────────────────────────────────────────────────
RUN sudo apt-get update && \
    sudo apt-get install -y git unzip zip jq openssh-client curl git-lfs perl && \
    sudo apt-get clean && \
    curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    sudo apt-get install -y nodejs

# Install Python 3.11 and pip3 securely
RUN sudo apt-get update && \
    sudo apt-get install -y software-properties-common && \
    for i in 1 2 3; do \
        sudo add-apt-repository ppa:deadsnakes/ppa -y && break || \
        (echo "PPA add failed (attempt $i/3), retrying in 10 seconds..." && sleep 10); \
    done && \
    sudo apt-get update && \
    sudo apt-get install -y python3.11 python3.11-venv python3.11-dev python3-pip && \
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip setuptools wheel

# ──────────────────────────────────────────────────────────────────────────────
# AWS CLI v2
# ──────────────────────────────────────────────────────────────────────────────
RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && sudo unzip awscliv2.zip \
    && sudo ./aws/install \
    && sudo rm -rf aws awscliv2.zip

# ──────────────────────────────────────────────────────────────────────────────
# IaC tooling (Atmos, Terraform, tfcmt, terraform-docs, Infracost)
# ──────────────────────────────────────────────────────────────────────────────
RUN set -eux; \
    ARCH="$(uname -m)"; \
    case "$ARCH" in \
        x86_64) ARCH='amd64' ;; \
        aarch64) ARCH='arm64' ;; \
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;; \
    esac; \
    \
    echo "Installing Atmos CLI v${ATMOS_VERSION}..."; \
    curl -fsSL "https://github.com/cloudposse/atmos/releases/download/v${ATMOS_VERSION}/atmos_${ATMOS_VERSION}_linux_${ARCH}" -o /tmp/atmos && \
    sudo install -m 755 /tmp/atmos /usr/local/bin/atmos && \
    rm /tmp/atmos && \
    atmos version && \
    \
    echo "Installing Terraform v${TERRAFORM_VERSION}..."; \
    curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" -o /tmp/terraform.zip && \
    sudo unzip -q /tmp/terraform.zip -d /usr/local/bin/ && \
    rm /tmp/terraform.zip && \
    terraform version && \
    \
    echo "Installing tfcmt v${TFCMT_VERSION}..."; \
    curl -fsSL "https://github.com/suzuki-shunsuke/tfcmt/releases/download/v${TFCMT_VERSION}/tfcmt_linux_${ARCH}.tar.gz" -o /tmp/tfcmt.tar.gz && \
    sudo tar -xzf /tmp/tfcmt.tar.gz -C /usr/local/bin/ tfcmt && \
    rm /tmp/tfcmt.tar.gz && \
    tfcmt --version && \
    \
    echo "Installing terraform-docs v${TERRAFORM_DOCS_VERSION}..."; \
    curl -fsSL "https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-${ARCH}.tar.gz" -o /tmp/terraform-docs.tar.gz && \
    sudo tar -xzf /tmp/terraform-docs.tar.gz -C /usr/local/bin/ terraform-docs && \
    rm /tmp/terraform-docs.tar.gz && \
    terraform-docs --version && \
    \
    echo "Installing Infracost v${INFRACOST_VERSION}..."; \
    curl -fsSL "https://github.com/infracost/infracost/releases/download/v${INFRACOST_VERSION}/infracost-linux-${ARCH}.tar.gz" -o /tmp/infracost.tar.gz && \
    tar -xzf /tmp/infracost.tar.gz -C /tmp/ && \
    sudo install -m 755 /tmp/infracost-linux-${ARCH} /usr/local/bin/infracost && \
    rm -rf /tmp/infracost* && \
    infracost --version && \
    \
    echo "All IaC tools installed successfully!"

# ──────────────────────────────────────────────────────────────────────────────
# Kubernetes tooling (Helm, Helmfile, kubectl, helm-diff)
# ──────────────────────────────────────────────────────────────────────────────
RUN set -eux; \
    ARCH="$(uname -m)"; \
    case "$ARCH" in \
        x86_64) ARCH='amd64' ;; \
        aarch64) ARCH='arm64' ;; \
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;; \
    esac; \
    \
    echo "Installing Helm v${HELM_VERSION}..."; \
    curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz" -o /tmp/helm.tar.gz && \
    tar -xzf /tmp/helm.tar.gz -C /tmp/ && \
    sudo install -m 755 /tmp/linux-${ARCH}/helm /usr/local/bin/helm && \
    rm -rf /tmp/helm.tar.gz /tmp/linux-${ARCH} && \
    helm version && \
    \
    echo "Installing Helmfile v${HELMFILE_VERSION}..."; \
    curl -fsSL "https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_${ARCH}.tar.gz" -o /tmp/helmfile.tar.gz && \
    tar -xzf /tmp/helmfile.tar.gz -C /tmp/ helmfile && \
    sudo install -m 755 /tmp/helmfile /usr/local/bin/helmfile && \
    rm -f /tmp/helmfile.tar.gz /tmp/helmfile && \
    helmfile --version && \
    \
    echo "Installing kubectl v${KUBECTL_VERSION}..."; \
    curl -fsSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl" -o /tmp/kubectl && \
    sudo install -m 755 /tmp/kubectl /usr/local/bin/kubectl && \
    rm /tmp/kubectl && \
    kubectl version --client && \
    \
    echo "Kubernetes tools installed successfully!"

ENV HELM_DATA_HOME=/usr/local/share/helm
RUN sudo mkdir -p ${HELM_DATA_HOME} && sudo chown $(whoami) ${HELM_DATA_HOME} && \
    helm plugin install https://github.com/databus23/helm-diff --version v${HELM_DIFF_VERSION}

# ──────────────────────────────────────────────────────────────────────────────
# SSH & workspace setup
# ──────────────────────────────────────────────────────────────────────────────
RUN mkdir -p ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN mkdir -p ./rootfs/usr/local/etc/atmos/
