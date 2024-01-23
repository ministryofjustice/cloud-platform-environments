#!/usr/bin/env bash

set -e

source /usr/local/bin/devcontainer-utils

get_system_architecture

TERRAFORM_SWITCHER_GITHUB_REPOSITORY="warrensbox/terraform-switcher"
TERRAFORM_SWITCHER_VERSION=${TERRAFORMSWITCHERVERSION:-"latest"}

TERRAFORM_GITHUB_REPOSITORY="hashicorp/terraform"
TERRAFORM_VERSION=${TERRAFORMVERSION:-"latest"}


if [[ "${TERRAFORM_SWITCHER_VERSION}" == "latest" ]]; then
  get_github_latest_tag "${TERRAFORM_SWITCHER_GITHUB_REPOSITORY}"
  TERRAFORM_SWITCHER_VERSION="${GITHUB_LATEST_TAG}"
  TERRAFORM_SWITCHER_VERSION_STRIP_V="${GITHUB_LATEST_TAG_STRIP_V}"
else
  TERRAFORM_SWITCHER_VERSION_STRIP_V="${TERRAFORM_SWITCHER_VERSION#v}"
fi

if [[ "${TERRAFORM_VERSION}" == "latest" ]]; then
  get_github_latest_tag "${TERRAFORM_GITHUB_REPOSITORY}"
  TERRAFORM_VERSION="${GITHUB_LATEST_TAG}"
  TERRAFORM_VERSION_STRIP_V="${GITHUB_LATEST_TAG_STRIP_V}"
else
  TERRAFORM_VERSION_STRIP_V="${TERRAFORM_VERSION#v}"
fi

curl --fail-with-body --location "https://github.com/${TERRAFORM_SWITCHER_GITHUB_REPOSITORY}/releases/download/${TERRAFORM_SWITCHER_VERSION}/terraform-switcher_${TERRAFORM_SWITCHER_VERSION}_linux_${ARCHITECTURE}.tar.gz" \
  --output "terraform-switcher_${TERRAFORM_SWITCHER_VERSION}_linux_${ARCHITECTURE}.tar.gz"

tar --gzip --extract --file "terraform-switcher_${TERRAFORM_SWITCHER_VERSION}_linux_${ARCHITECTURE}.tar.gz"

install --owner=vscode --group=vscode --mode=775 tfswitch /usr/local/bin/tfswitch

rm --force --recursive CHANGELOG.md LICENSE README.md "terraform-switcher_${TERRAFORM_SWITCHER_VERSION}_linux_${ARCHITECTURE}.tar.gz"

install --directory --owner=vscode --group=vscode /home/vscode/.terraform-bin

install --owner=vscode --group=vscode --mode=775 "$(dirname "${0}")"/src/home/vscode/.tfswitch.toml /home/vscode/.tfswitch.toml

install --owner=vscode --group=vscode --mode=775 "$(dirname "${0}")"/src/home/vscode/.devcontainer/feature-completion/terraform.sh /home/vscode/.devcontainer/feature-completion/terraform.sh

su - vscode --command "tfswitch ${TERRAFORM_VERSION_STRIP_V}"
