#!/usr/bin/env bash
set -eo pipefail

# Fetch the latest version of hadolint CLI
get_latest_cli_version() {
    HADOLINT_VERSION=$(curl -L -s https://api.github.com/repos/hadolint/hadolint/releases/latest | jq -r .tag_name)
    HADOLINT_VERSION="${HADOLINT_VERSION//v}"
}

# Install hadolint
install_hadolint_cli() {
    echo "Installing hadolint version v${HADOLINT_VERSION}"
    curl -L "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64" --output hadolint-Linux-x86_64
    sudo mv hadolint-Linux-x86_64 /usr/local/bin/hadolint
    sudo chmod +x /usr/local/bin/hadolint
}

if [[ "$HADOLINT_VERSION" == "latest" ]]; then
    get_latest_cli_version
fi

install_hadolint_cli
hadolint --version