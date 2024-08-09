FROM ghcr.io/actions/actions-runner:latest

# Install git
RUN sudo apt-get update && \
    sudo apt-get install -y git unzip jq openssh-client && \
    sudo apt-get clean && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    sudo apt-get install -y nodejs \
    sudo rm -rf /var/lib/apt/lists/*

