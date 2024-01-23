#!/usr/bin/env bash

set -e

source /usr/local/bin/devcontainer-utils

logger "info" "Installing AWS CLI (version: ${AWSCLIVERSION})"
bash "$(dirname "${0}")"/install-aws-cli.sh
