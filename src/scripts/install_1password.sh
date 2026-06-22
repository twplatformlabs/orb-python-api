#!/usr/bin/env bash
set -eo pipefail

CLI_URL="https://app-updates.agilebits.com/product_history/CLI2"

# Fetch the latest version of 1Password CLI (on stable or beta channel)
get_latest_cli_version() {
    conditional_path="/beta/"
    if [ "$1" == "non_beta" ]; then
        conditional_path="!/beta/"
    fi

    OP_VERSION="v$(curl -s "$CLI_URL" | awk -v RS='<h3>|</h3>' 'NR % 2 == 0 {gsub(/[[:blank:]]+/, ""); gsub(/<span[^>]*>|<\/span>|[\r\n]+/, ""); gsub(/&nbsp;.*$/, ""); if (!'"$1"' && '"$conditional_path"'){print; '"$1"'=1;}}')"
}

# Install op-cli
install_op_cli() {
    echo "Installing 1Password CLI version: ${OP_VERSION}"
    curl -sSfLo op.zip "https://cache.agilebits.com/dist/1P/op2/pkg/${OP_VERSION}/op_linux_amd64_${OP_VERSION}.zip"
    sudo unzip -od /usr/local/bin op.zip
    rm op.zip
}

if [[ "$OP_VERSION" == "latest" ]]; then
    get_latest_cli_version non_beta
elif [[ "$OP_VERSION" == "latest-beta" ]]; then
    get_latest_cli_version beta
else
    OP_VERSION="v$OP_VERSION"
fi
echo "$OP_VERSION"
install_op_cli
op --version
              