#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "tfswitch version" tfswitch --version
check "terraform version" /home/vscode/.terraform-bin/terraform -version
check "terraform completions existence" stat /home/vscode/.devcontainer/feature-completion/terraform.sh
check "tfswitch configuration existence" stat /home/vscode/.tfswitch.toml

reportResults
