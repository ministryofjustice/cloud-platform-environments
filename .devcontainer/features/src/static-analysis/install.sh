#!/usr/bin/env bash

set -e

source /usr/local/bin/devcontainer-utils

logger "info" "Installing Trivy (version: ${TRIVYVERSION})"
bash "$(dirname "${0}")"/install-trivy.sh
