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
      python3.10 \
      python3.10-venv \
      python3.10-distutils \
      python3-pip \
      unzip && \
      ln -sf /usr/bin/python3.10 /usr/bin/python3 && \
      ln -sf /usr/bin/pip3 /usr/bin/pip && \
    # Helm
    curl -LO "https://get.helm.sh/helm-v3.14.3-linux-amd64.tar.gz" && \
    tar -zxvf helm-v3.14.3-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf helm-v3.14.3-linux-amd64.tar.gz linux-amd64 && \
    # Kubernetis
    curl -LO "https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/ && \
    # Pip
    pip3 install --upgrade pip && \
    pip3 install pytest && \
    # SonarScanner
    curl -sSLo sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip && \
    unzip sonar-scanner.zip -d /opt && \
    ln -s /opt/sonar-scanner-*/bin/sonar-scanner /usr/local/bin/sonar-scanner && \
    rm sonar-scanner.zip && \
    # clean
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/sonar-scanner-*/bin:$PATH"

ENTRYPOINT ["cat"]
