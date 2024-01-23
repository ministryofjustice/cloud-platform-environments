#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "kubectl version" kubectl version --client=true --output yaml
check "kubeconfig existence" stat /home/vscode/.kube/config
check "kubectl completions existence" stat /home/vscode/.devcontainer/feature-completion/kubectl.sh

reportResults
