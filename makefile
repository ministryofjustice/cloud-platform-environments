TOOLS_IMAGE := ministryofjustice/cloud-platform-tools:1.43

namespace-report.json: bin/namespace-reporter.rb namespaces/live-1.cloud-platform.service.justice.gov.uk/*/*.yaml
	./bin/namespace-reporter.rb -o json -n '.*' > namespace-report.json

export NAMESPACE_MESSAGE

pull-tools:
	@echo "Pulling Cloud Platform Tools docker image..."
	@docker pull $(TOOLS_IMAGE) > /dev/null

# This will mount the tools shell with the root folder of cloud-platform-environments
# Make sure you have the below env variables set before launching the tools shell
# AWS_PROFILE, AUTH0_DOMAIN, AUTH0_CLIENT_ID, AUTH0_CLIENT_SECRET, KOPS_STATE_STORE
tools-shell:
  docker pull --platform=linux/amd64 $(TOOLS_IMAGE)
  docker run --platform=linux/amd64 --rm -it \
    -e AWS_PROFILE=$${AWS_PROFILE} \
    -e AUTH0_DOMAIN=$${AUTH0_DOMAIN} \
    -e AUTH0_CLIENT_ID=$${AUTH0_CLIENT_ID} \
    -e AUTH0_CLIENT_SECRET=$${AUTH0_CLIENT_SECRET} \
    -e KOPS_STATE_STORE=$${KOPS_STATE_STORE} \
  -e KUBE_CONFIG_PATH=~/.kube/config \
    -v $$(pwd):/app \
    -v $${HOME}/.aws:/root/.aws \
    -v $${HOME}/.gnupg:/root/.gnupg \
    -v $${HOME}/.docker:/root/.docker \
    -w /app \
    $(TOOLS_IMAGE) bash

# Launch a tools shell on a pod in the cluster. This can be useful if e.g. you
# need to run terraform code that manipulates an RDS database instance, since
# you won't be able to access any AWS resources from outside the cloud platform
# VPC.
#
# Note: This command is optimised to be able to run terraform on a namespace, so
# it expects a lot of environment variables which you won't necessarily need.
#
# NB: You *must* have a NAMESPACE environment variable set.
#
tools-shell-in-cluster:
	kubectl run tools-image --rm -it \
		-n $${NAMESPACE} \
		--attach=true \
		--generator=run-pod/v1 \
		--image=$(TOOLS_IMAGE) \
		--env="KOPS_STATE_STORE=s3://cloud-platform-kops-state" \
		--env="PIPELINE_CLUSTER=live-1.cloud-platform.service.justice.gov.uk" \
		--env="TF_VAR_cluster_name=live-1" \
		--env="TF_VAR_cluster_state_bucket=cloud-platform-terraform-state" \
		--env="TF_VAR_cluster_state_key=cloud-platform/live-1/terraform.tfstate" \
		--env="AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID}" \
		--env="AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY}" \
		--env="AWS_DEFAULT_REGION=eu-west-2" \
		bash


### Conftest

# Test all the kubernetes yaml files against all the policies defined in the `policy` directory
conftest:
	ls -1 namespaces/live-1.cloud-platform.service.justice.gov.uk/*/*.y*ml \
		| xargs -n 200 conftest test

# Run the rego policy tests
policy-tests:
	opa test ./policy

.PHONY: pull-tools tools-shell tools-shell-in-cluster conftest policy-tests
