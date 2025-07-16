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

RUN mkdir -p ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN mkdir -p ./rootfs/usr/local/etc/atmos/
