TOOLS_IMAGE := ministryofjustice/cloud-platform-tools:1.8

namespace-report.json: bin/namespace-reporter.rb namespaces/live-1.cloud-platform.service.justice.gov.uk/*/*.yaml
	./bin/namespace-reporter.rb -o json -n '.*' > namespace-report.json

# Ugly hack to define a heredoc in a makefile
# https://stackoverflow.com/questions/5873025/heredoc-in-a-makefile
define NAMESPACE_MESSAGE
Please create a new branch of this repository, add the files above and raise a
pull request.  Once the PR has been approved by the cloud platform team, please
merge it and delete the branch.  Shortly after that, your new namespace will be
created via the build pipeline.
endef
export NAMESPACE_MESSAGE

# Create a new namespace
namespace:
	@echo "Pulling Cloud Platform Tools docker image..."
	@docker pull $(TOOLS_IMAGE) > /dev/null
	@echo "Creating namespace..."
	@docker run --rm -it -v $$(pwd):/app -w /app $(TOOLS_IMAGE) bin/create-namespace-files.rb
	@git status --untracked-files=all
	@echo
	@echo $${NAMESPACE_MESSAGE} | fmt
	@echo

# Set an env. var called APPDIR to the source code directory
# you want to mount into your tools shell
tools-shell:
	@echo "Pulling Cloud Platform Tools docker image..."
	@docker pull $(TOOLS_IMAGE) > /dev/null
	@docker run --rm -it \
		-v $${APPDIR}:/app \
		-v $${HOME}/.kube:/app/.kube \
		-e KUBECONFIG=/app/.kube/config \
		-v $${HOME}/.aws:/root/.aws \
		-v $${HOME}/.gnupg:/root/.gnupg \
		-w /app $(TOOLS_IMAGE) bash
