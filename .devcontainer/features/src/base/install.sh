#!/usr/bin/env bash

set -e

source "$(dirname "${0}")"/src/usr/local/bin/devcontainer-utils

install --owner=vscode --group=vscode --mode=775 "$(dirname "${0}")"/src/usr/local/bin/devcontainer-utils /usr/local/bin/devcontainer-utils

install --owner=vscode --group=vscode --mode=755 "$(dirname "${0}")"/src/usr/local/etc/vscode-dev-containers/first-run-notice.txt /usr/local/etc/vscode-dev-containers/first-run-notice.txt

install --owner=vscode --group=vscode --mode=755 "$(dirname "${0}")"/src/home/vscode/.oh-my-zsh/custom/themes/devcontainers.zsh-theme /home/vscode/.oh-my-zsh/custom/themes/devcontainers.zsh-theme

install --directory --owner=vscode --group=vscode /home/vscode/.devcontainer/feature-completion

cat <<EOF >> /home/vscode/.zshrc

# dev container feature completion scripts
for file in "\${HOME}"/.devcontainer/feature-completion/*.sh; do
  source "\${file}"
done
EOF
