TOOLS_IMAGE := ministryofjustice/cloud-platform-tools:2.7.0

pull-tools:
	@echo "Pulling Cloud Platform Tools docker image..."
	@docker pull $(TOOLS_IMAGE) > /dev/null

# This will mount the tools shell with the root folder of cloud-platform-environments
# Make sure you have the below env variables set before launching the tools shell
# AWS_PROFILE, AUTH0_DOMAIN, AUTH0_CLIENT_ID, AUTH0_CLIENT_SECRET
tools-shell:
	docker pull --platform=linux/amd64 $(TOOLS_IMAGE)
	docker run --platform=linux/amd64 --rm -it \
		-e AWS_PROFILE=$${AWS_PROFILE} \
		-e AUTH0_DOMAIN=$${AUTH0_DOMAIN} \
		-e AUTH0_CLIENT_ID=$${AUTH0_CLIENT_ID} \
		-e AUTH0_CLIENT_SECRET=$${AUTH0_CLIENT_SECRET} \
		-e KUBE_CONFIG_PATH=/root/.kube/config \
		-e KUBECONFIG=/root/.kube/config \
		-v $$(pwd):/app \
		-v $${HOME}/.aws:/root/.aws \
		-v $${HOME}/.gnupg:/root/.gnupg \
		-v $${HOME}/.docker:/root/.docker \
		-w /app \
		$(TOOLS_IMAGE) bash

### Conftest

# Test all the kubernetes yaml files against all the policies defined in the `policy` directory
conftest:
	ls -1 namespaces/live.cloud-platform.service.justice.gov.uk/*/*.y*ml \
		| xargs -n 200 conftest test

# Run the rego policy tests
policy-tests:
	opa test ./policy

.PHONY: pull-tools tools-shell conftest policy-tests
