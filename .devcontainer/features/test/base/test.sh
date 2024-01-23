#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "devcontainer-utils file existence" stat /usr/local/bin/devcontainer-utils
check "first-run-notice.txt file existence" stat /usr/local/etc/vscode-dev-containers/first-run-notice.txt
check "devcontainer feature completion directory existence" stat /home/vscode/.devcontainer/feature-completion
check "dev container theme file existence" stat /home/vscode/.oh-my-zsh/custom/themes/devcontainers.zsh-theme
check "feature completion zshrc snippet existence" grep -q "dev container feature completion scripts" /home/vscode/.zshrc

reportResults
