#!/usr/bin/env bash

set -e

source /usr/local/bin/devcontainer-utils

get_system_architecture

GITHUB_REPOSITORY="ministryofjustice/cloud-platform-cli"
VERSION=${AWSSSOCLIVERSION:-"latest"}

if [[ "${VERSION}" == "latest" ]]; then
  get_github_latest_tag "${GITHUB_REPOSITORY}"
  VERSION="${GITHUB_LATEST_TAG}"
  VERSION_STRIP_V="${GITHUB_LATEST_TAG_STRIP_V}"
else
  VERSION_STRIP_V="${VERSION#v}"
fi

curl --fail-with-body --location "https://github.com/${GITHUB_REPOSITORY}/releases/download/${VERSION}/cloud-platform-cli_${VERSION}_linux_${ARCHITECTURE}.tar.gz" \
  --output "cloud-platform-cli_${VERSION}_linux_${ARCHITECTURE}.tar.gz"

tar --gzip --extract --file "cloud-platform-cli_${VERSION}_linux_${ARCHITECTURE}.tar.gz"

install --owner=vscode --group=vscode --mode=775 cloud-platform /usr/local/bin/cloud-platform

install --owner=vscode --group=vscode --mode=775 completions/cloud-platform.zsh /usr/local/share/zsh/site-functions/_cloud-platform

rm --recursive --force LICENSE README.md completions cloud-platform-cli_${VERSION}_linux_${ARCHITECTURE}.tar.gz
