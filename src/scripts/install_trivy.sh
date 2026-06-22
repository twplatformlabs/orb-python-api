#!/usr/bin/env bash
set -eo pipefail

# Fetch the latest version of trivy CLI
get_latest_cli_version() {
    TRIVY_VERSION=$(curl -L -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | jq -r .tag_name)
    TRIVY_VERSION="${TRIVY_VERSION//v}"
}

# Install trivy
install_trivy_cli() {
    echo "Installing trivy version v${TRIVY_VERSION}"
    curl -L "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" --output "trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz"
    sudo tar -xzf "trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" -C /usr/local/bin trivy
    rm "trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz"
}

if [[ "$TRIVY_VERSION" == "latest" ]]; then
    get_latest_cli_version
fi

install_trivy_cli
trivy version