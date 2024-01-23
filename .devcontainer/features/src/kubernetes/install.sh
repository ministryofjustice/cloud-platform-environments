#!/usr/bin/env bash

set -e

source /usr/local/bin/devcontainer-utils

logger "info" "Installing Kubernetes CLI (version: ${KUBERNETESCLIVERSION})"
bash "$(dirname "${0}")"/install-kubernetes-cli.sh
