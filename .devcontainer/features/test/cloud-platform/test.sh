#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "cloud-platform version" cloud-platform version
check "cloud-platform completions existence" stat /usr/local/share/zsh/site-functions/_cloud-platform

reportResults
