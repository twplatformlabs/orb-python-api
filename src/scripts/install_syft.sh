#!/usr/bin/env bash
set -eo pipefail

# Fetch the latest version of Syft CLI
get_latest_cli_version() {
    SYFT_VERSION=$(curl -L -s https://api.github.com/repos/anchore/syft/releases/latest | jq -r .tag_name)
    SYFT_VERSION="${SYFT_VERSION//v}"
}

# Install syft
install_syft_cli() {
    echo "Installing syft version v${SYFT_VERSION}"
    sudo bash -c "curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin v${SYFT_VERSION}"
}

if [[ "$SYFT_VERSION" == "latest" ]]; then
    get_latest_cli_version
fi

install_syft_cli
syft version