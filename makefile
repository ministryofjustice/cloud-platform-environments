TOOLS_IMAGE := 754256621582.dkr.ecr.eu-west-2.amazonaws.com/cloud-platform/tools

namespace-report.json: bin/namespace-reporter.rb namespaces/live-1.cloud-platform.service.justice.gov.uk/*/*.yaml
	./bin/namespace-reporter.rb -o json -n '.*' > namespace-report.json

# Create a new namespace
namespace:
	@echo "Authenticating to ECR & pulling Cloud Platform Tools docker image..."
	@export AWS_PROFILE=moj-cp; ( $$(aws ecr get-login --no-include-email); docker pull $(TOOLS_IMAGE) > /dev/null )
	@echo "Creating namespace..."
	@docker run --rm -it -v $$(pwd):/app -w /app $(TOOLS_IMAGE) bash -c 'cd namespace-resources; terraform init; terraform apply -auto-approve'
	@git status --untracked-files=all
