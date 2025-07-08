FROM ghcr.io/actions/actions-runner:latest

# Package configurations
ARG ATMOS_VERSION=1.182.0
ARG TERRAFORM_VERSION=1.9.8
ARG INSTALL_DIR=/usr/local/bin

# Install git
RUN sudo apt-get update && \
    sudo apt-get install -y git unzip jq openssh-client curl git-lfs perl gnupg ca-certificates && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    sudo apt-get install -y nodejs && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && sudo unzip awscliv2.zip \
    && sudo ./aws/install \
    && sudo rm -rf aws awscliv2.zip

RUN mkdir -p ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

# Install Terraform
RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS" -o terraform_SHA256SUMS && \
    grep "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" terraform_SHA256SUMS | sha256sum -c - && \
    sudo unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d ${INSTALL_DIR} && \
    sudo chmod +x ${INSTALL_DIR}/terraform && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_SHA256SUMS

# Install ATMOS
RUN curl -fsSL "https://github.com/cloudposse/atmos/releases/download/v${ATMOS_VERSION}/atmos_${ATMOS_VERSION}_linux_amd64" -o atmos && \
    sudo mv atmos ${INSTALL_DIR}/ && \
    sudo chmod +x ${INSTALL_DIR}/atmos

RUN mkdir -p ./rootfs/usr/local/etc/atmos/
