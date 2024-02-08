#!/bin/bash

TERRAFORM_PLAN=/tmp/terraform-plan
MODULES_TO_CHECK_FOR=(
  module.ecr_credentials,
  module.service_accounts,
  module.secrets_manager
)

LIST = $(terraform show -json $TERRAFORM_PLAN | jq -r '.resource_changes[].address)
for module in "${LIST[@]}" ; do
  if [[ " ${MODULES_TO_CHECK_FOR[@]} " =~ " ${module} " ]]; then
    echo "Module $module is present in the plan"
    echo "::set-output name=approval_required::true"
  else
    echo "Module $module is not present in the plan"
    echo "::set-output name=approval_required::false"
  fi
done