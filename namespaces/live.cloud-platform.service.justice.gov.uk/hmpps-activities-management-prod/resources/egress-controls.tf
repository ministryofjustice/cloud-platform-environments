# Deploys Envoy HTTPS forward proxy and creates proxy environment secret.
# For guidance see: https://tech-docs.hmpps.service.justice.gov.uk/how-to-guides/retrofitting-egress-controls-with-envoy-proxy

module "hmpps_egress_controls" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-egress-controls?ref=0.0.6"

  enable_envoy_setup     = true
  enable_egress_controls = false 

  namespace = var.namespace
  vpc_name  = var.vpc_name

  envoy_extra_allowed_hosts_exact = [
    "www.gov.uk", # required for fetching bank-holidays.json file
    "o345774.ingest.sentry.io"
  ]

  envoy_extra_allowed_hosts_suffixes = [
  ]

}