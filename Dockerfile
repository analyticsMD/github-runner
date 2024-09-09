FROM ghcr.io/actions/actions-runner:latest

# Install git
RUN sudo apt-get update && \
    sudo apt-get install -y git unzip jq openssh-client curl git-lfs perl && \
    sudo apt-get clean && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    sudo apt-get install -y nodejs

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && sudo unzip awscliv2.zip \
    && sudo ./aws/install \
    && sudo rm -rf aws awscliv2.zip

RUN mkdir -p ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts