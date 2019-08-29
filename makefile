TOOLS_IMAGE := ministryofjustice/cloud-platform-tools

namespace-report.json: bin/namespace-reporter.rb namespaces/live-1.cloud-platform.service.justice.gov.uk/*/*.yaml
	./bin/namespace-reporter.rb -o json -n '.*' > namespace-report.json

# Create a new namespace
namespace:
	@echo "Pulling Cloud Platform Tools docker image..."
	@docker pull $(TOOLS_IMAGE) > /dev/null
	@echo "Creating namespace..."
	@docker run --rm -it -v $$(pwd):/app -w /app $(TOOLS_IMAGE) bash -c 'cd namespace-resources; terraform init; terraform apply -auto-approve'
	@git status --untracked-files=all
