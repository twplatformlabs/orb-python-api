#!/usr/bin/env bash
set -eo pipefail

# Fetch the latest version of cosign CLI
get_latest_cli_version() {
    COSIGN_VERSION=$(curl -L -s https://api.github.com/repos/sigstore/cosign/releases/latest | jq -r .tag_name)
    COSIGN_VERSION="${COSIGN_VERSION//v}"
}

# Install cosign
install_cosign_cli() {
    echo "Installing cosign version v${COSIGN_VERSION}"
    curl -L "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-amd64" --output cosign
    chmod +x cosign && sudo mv cosign /usr/local/bin/cosign
}

if [[ "$COSIGN_VERSION" == "latest" ]]; then
    get_latest_cli_version
fi

install_cosign_cli
cosign version