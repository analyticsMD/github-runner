FROM ghcr.io/actions/actions-runner:latest

# Install git
RUN sudo apt-get update && \
    sudo apt-get install -y git unzip zip jq openssh-client curl git-lfs perl && \
    sudo apt-get clean && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    sudo apt-get install -y nodejs

# Install Python 3.11 and pip3 securely
RUN sudo apt-get update && \
    sudo apt-get install -y software-properties-common && \
    sudo add-apt-repository ppa:deadsnakes/ppa -y && \
    sudo apt-get update && \
    sudo apt-get install -y python3.11 python3.11-venv python3.11-dev python3-pip && \
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Upgrade pip to latest version for security
RUN python3 -m pip install --upgrade pip setuptools wheel

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && sudo unzip awscliv2.zip \
    && sudo ./aws/install \
    && sudo rm -rf aws awscliv2.zip

# Install workflow tools to avoid GitHub API rate limits during execution
# All tools are installed in a single layer to minimize image size
RUN set -eux; \
    ARCH="$(uname -m)"; \
    case "$ARCH" in \
        x86_64) ARCH='amd64' ;; \
        aarch64) ARCH='arm64' ;; \
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;; \
    esac; \
    \
    # Install Atmos CLI v1.195.0
    echo "Installing Atmos CLI v1.195.0..."; \
    curl -fsSL "https://github.com/cloudposse/atmos/releases/download/v1.195.0/atmos_1.195.0_linux_${ARCH}" -o /tmp/atmos && \
    sudo install -m 755 /tmp/atmos /usr/local/bin/atmos && \
    rm /tmp/atmos && \
    atmos version && \
    \
    # Install Terraform (latest stable - 1.10.4)
    echo "Installing Terraform v1.10.4..."; \
    curl -fsSL "https://releases.hashicorp.com/terraform/1.10.4/terraform_1.10.4_linux_${ARCH}.zip" -o /tmp/terraform.zip && \
    sudo unzip -q /tmp/terraform.zip -d /usr/local/bin/ && \
    rm /tmp/terraform.zip && \
    terraform version && \
    \
    # Install tfcmt v4.14.0
    echo "Installing tfcmt v4.14.0..."; \
    curl -fsSL "https://github.com/suzuki-shunsuke/tfcmt/releases/download/v4.14.0/tfcmt_linux_${ARCH}.tar.gz" -o /tmp/tfcmt.tar.gz && \
    sudo tar -xzf /tmp/tfcmt.tar.gz -C /usr/local/bin/ tfcmt && \
    rm /tmp/tfcmt.tar.gz && \
    tfcmt --version && \
    \
    # Install terraform-docs v0.18.0
    echo "Installing terraform-docs v0.18.0..."; \
    curl -fsSL "https://github.com/terraform-docs/terraform-docs/releases/download/v0.18.0/terraform-docs-v0.18.0-linux-${ARCH}.tar.gz" -o /tmp/terraform-docs.tar.gz && \
    sudo tar -xzf /tmp/terraform-docs.tar.gz -C /usr/local/bin/ terraform-docs && \
    rm /tmp/terraform-docs.tar.gz && \
    terraform-docs --version && \
    \
    echo "All tools installed successfully!"

RUN mkdir -p ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN mkdir -p ./rootfs/usr/local/etc/atmos/
