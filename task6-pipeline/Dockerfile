FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
      curl \
      gnupg2 \
      ca-certificates \
      bash \
      git \
      docker.io \
      python3 \
      python3-pip && \
    curl -LO "https://get.helm.sh/helm-v3.14.3-linux-amd64.tar.gz" && \
    tar -zxvf helm-v3.14.3-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf helm-v3.14.3-linux-amd64.tar.gz linux-amd64 && \
    curl -LO "https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/ && \
    pip3 install --upgrade pip && \
    pip3 install pytest && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["cat"]
