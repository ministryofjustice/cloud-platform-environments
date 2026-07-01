# Deploys Envoy HTTPS forward proxy and creates proxy environment secret
# For guidance see: https://tech-docs.hmpps.service.justice.gov.uk/how-to-guides/retrofitting-egress-controls-with-envoy-proxy

module "hmpps_egress_controls" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-egress-controls?ref=0.0.5"

  enable_envoy_setup     = true
  enable_egress_controls = false 

  namespace = var.namespace
  vpc_name  = var.vpc_name

  # Add your service's external dependencies
  envoy_extra_allowed_hosts_exact = [
    "oidc.integration.account.gov.uk",
    "home.integration.account.gov.uk"
  ]

  envoy_extra_allowed_hosts_suffixes = [
  ]

}