#!/usr/bin/env bash

export PATH="${PATH}:${HOME}/.terraform-bin"

complete -o nospace -C ${HOME}/.terraform-bin/terraform terraform
