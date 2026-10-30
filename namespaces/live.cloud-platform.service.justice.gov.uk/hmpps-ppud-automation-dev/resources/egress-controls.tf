# Deploys Envoy HTTPS forward proxy and creates proxy environment secret
# For guidance see: https://tech-docs.hmpps.service.justice.gov.uk/how-to-guides/retrofitting-egress-controls-with-envoy-proxy

module "hmpps_egress_controls" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-egress-controls?ref=0.0.13"

  enable_envoy_setup     = true

  namespace = var.namespace
  vpc_name  = var.vpc_name

  # Add your service's external dependencies
  envoy_extra_allowed_hosts_exact = [
    "internaltest.ppud.justice.gov.uk",
    "github.com"
  ]

  envoy_extra_allowed_hosts_suffixes = [
    ".githubusercontent.com",
  ]

}
