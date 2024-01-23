#!/usr/bin/env bash

set -e

source /usr/local/bin/devcontainer-utils

get_system_architecture

GITHUB_REPOSITORY="ministryofjustice/cloud-platform-cli"
VERSION=${KUBERNETESCLIVERSION:-"latest"}

if [[ "${VERSION}" == "latest" ]]; then
  VERSION=$( curl --location --silent https://dl.k8s.io/release/stable.txt )
  VERSION_STRIP_V="${VERSION#v}"
else
  VERSION_STRIP_V="${VERSION#v}"
fi

curl --fail-with-body --location "https://dl.k8s.io/release/${VERSION}/bin/linux/${ARCHITECTURE}/kubectl" \
  --output "kubectl"

install --owner=vscode --group=vscode --mode=775 kubectl /usr/local/bin/kubectl

install --directory --owner=vscode --group=vscode /home/vscode/.kube

install --owner=vscode --group=vscode --mode=775 "$(dirname "${0}")"/src/home/vscode/.kube/config /home/vscode/.kube/config

install --owner=vscode --group=vscode --mode=775 "$(dirname "${0}")"/src/home/vscode/.devcontainer/feature-completion/kubectl.sh /home/vscode/.devcontainer/feature-completion/kubectl.sh
