#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "trivy version" trivy --version
check "trivy completions existence" stat /home/vscode/.devcontainer/feature-completion/trivy.sh

reportResults
