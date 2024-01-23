#!/usr/bin/env bash

set -e

source /usr/local/bin/devcontainer-utils

logger "info" "Installing Terraform Switcher (version: ${TERRAFORMSWITCHERVERSION})"
logger "info" "Installing Terraform (version: ${TERRAFORMVERSION})"
bash "$(dirname "${0}")"/install-terraform-switcher.sh
