#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "aws version" aws --version
check "aws completions existence" stat /home/vscode/.devcontainer/feature-completion/aws.sh

reportResults
