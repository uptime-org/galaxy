FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    bash \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Helm
RUN curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm

# Install gcloud CLI
RUN curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz | tar -xz -C /opt \
    && /opt/google-cloud-sdk/install.sh --quiet \
    && ln -s /opt/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud \
    && ln -s /opt/google-cloud-sdk/bin/kubectl /usr/local/bin/kubectl

# Create app directory and copy requirements
WORKDIR /app
COPY ci-test/requirements.txt /app/ci-requirements.txt
COPY requirements.txt /app/app-requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r ci-requirements.txt -r app-requirements.txt

# Copy and set up configuration files
COPY ci-test/.flake8 /app/.flake8
COPY ci-test/.bandit /app/.bandit

# Copy source code
COPY . /app/

# Set executable permissions for analysis script
RUN chmod +x /app/ci-test/analyze.sh

WORKDIR /app
ENTRYPOINT ["/app/ci-test/analyze.sh"]