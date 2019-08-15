namespace-report.json: bin/namespace-reporter.rb namespaces/live-1.cloud-platform.service.justice.gov.uk/*/*.yaml
	./bin/namespace-reporter.rb -o json -n '.*' > namespace-report.json
