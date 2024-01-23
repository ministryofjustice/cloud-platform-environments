#!/usr/bin/env bash

set -e

source /usr/local/bin/devcontainer-utils

logger "info" "Installing Cloud Platform CLI (version: ${CLOUDPLATFORMCLIVERSION})"
bash "$(dirname "${0}")"/install-cloud-platform-cli.sh
