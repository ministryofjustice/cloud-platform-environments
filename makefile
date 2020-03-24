TOOLS_IMAGE := ministryofjustice/cloud-platform-tools:1.13

namespace-report.json: bin/namespace-reporter.rb namespaces/live-1.cloud-platform.service.justice.gov.uk/*/*.yaml
	./bin/namespace-reporter.rb -o json -n '.*' > namespace-report.json

# Ugly hack to define a heredoc in a makefile
# https://stackoverflow.com/questions/5873025/heredoc-in-a-makefile
define NAMESPACE_MESSAGE
Please create a new branch of this repository, add the files above and raise a
pull request.  Once the PR has been approved by the cloud platform team, please
merge it.  Shortly after that, your new namespace will be created via the build
pipeline.
endef
export NAMESPACE_MESSAGE

pull-tools:
	@echo "Pulling Cloud Platform Tools docker image..."
	@docker pull $(TOOLS_IMAGE) > /dev/null

namespace-message:
	@git status --untracked-files=all
	@echo
	@echo $${NAMESPACE_MESSAGE} | fmt
	@echo

# Create a new namespace
namespace:
	@make pull-tools
	@echo "Creating namespace..."
	@docker run --rm -it -v $$(pwd):/app -w /app $(TOOLS_IMAGE) bin/create-namespace-files.rb $${ANSWERS_FILE}
	@make namespace-message

# Create a new namespace with 'gitops' continuous deployment
gitops-namespace:
	@make pull-tools
	@echo
	@echo "A deployment directory will be created in your application source code tree, "
	@echo "as part of the namespace creation process."
	@echo "Please provide the RELATIVE path to your working copy of your application source code."
	@echo
	@read -p "path: " working_copy_path; docker run --rm -it -v $$(pwd)/$${working_copy_path}:/appsrc -v $$(pwd):/app -w /app $(TOOLS_IMAGE) bin/create-gitops-namespace-files.rb $${ANSWERS_FILE}
	@make namespace-message

# Set an env. var called APPDIR to the source code directory
# you want to mount into your tools shell
tools-shell:
	@make pull-tools
	@docker run --rm -it \
		-v $${APPDIR}:/app \
		-v $${HOME}/.kube:/app/.kube \
		-e KUBECONFIG=/app/.kube/config \
		-v $${HOME}/.aws:/root/.aws \
		-v $${HOME}/.gnupg:/root/.gnupg \
		-w /app $(TOOLS_IMAGE) bash

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

.PHONY: pull-tools namespace namespace-message gitops-namespace tools-shell tools-shell-in-cluster
