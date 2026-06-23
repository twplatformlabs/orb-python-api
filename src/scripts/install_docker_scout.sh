#!/usr/bin/env bash
set -eo pipefail

# Fetch the latest version of Docker Scout
get_latest_cli_version() {
    SCOUT_VERSION="$(curl -s "https://api.github.com/repos/docker/scout-cli/releases/latest" | jq -r .tag_name)"
}

# Install docker_scout
install_docker_scout() {
    echo "Installing Docker Scout version: ${SCOUT_VERSION}"
    download_url="https://github.com/docker/scout-cli/releases/download/${SCOUT_VERSION}/docker-scout_${SCOUT_VERSION:1}_linux_amd64.tar.gz"
    curl -fL -O "${download_url}"
    tar -xzf "docker-scout_${SCOUT_VERSION:1}_linux_amd64.tar.gz" docker-scout && rm "docker-scout_${SCOUT_VERSION:1}_linux_amd64.tar.gz"
    sudo mkdir -p "$HOME/.docker/cli-plugins" && sudo mv docker-scout "$HOME/.docker/cli-plugins/docker-scout"
}

if [[ "$SCOUT_VERSION" == "latest" ]]; then
    get_latest_cli_version
else
    SCOUT_VERSION="v$SCOUT_VERSION"
fi
echo "$SCOUT_VERSION"
install_docker_scout
docker scout version
