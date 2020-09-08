for f in namespaces/live-1.cloud-platform.service.justice.gov.uk/*/00-namespace.yaml; do \
  grep -q slack $f || echo $f; \
done
