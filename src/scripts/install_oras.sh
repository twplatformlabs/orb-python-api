#!/usr/bin/env bash
set -eo pipefail

# Fetch the latest version of Oras CLI
get_latest_cli_version() {
    ORAS_VERSION=$(curl -L -s https://api.github.com/repos/oras-project/oras/releases/latest | jq -r .tag_name)
    ORAS_VERSION="${ORAS_VERSION//v}"
}

# Install oras
install_oras_cli() {
    echo "Installing oras version v${ORAS_VERSION}"
    curl -LO "https://github.com/oras-project/oras/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_amd64.tar.gz"
    mkdir -p oras-install &&
    tar -zxf "oras_${ORAS_VERSION}_linux_amd64.tar.gz" -C oras-install/
    sudo mv oras-install/oras /usr/local/bin/
    rm -rf "oras_${ORAS_VERSION}_linux_amd64.tar.gz" oras-install/
}

if [[ "$ORAS_VERSION" == "latest" ]]; then
    get_latest_cli_version
fi

install_oras_cli
oras version