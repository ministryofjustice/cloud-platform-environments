module "hmpps_egress_controls" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-egress-controls?ref=0.0.7"

  enable_envoy_setup     = true
  enable_egress_controls = false

  namespace              = var.namespace
  vpc_name               = var.vpc_name
  
  envoy_extra_allowed_hosts_exact = [
    "justiceuk.sharepoint.com",
    "circleci.com"
  ]

  envoy_extra_allowed_hosts_suffixes = [
    ".in.applicationinsights.azure.com",
    ".livediagnostics.monitor.azure.com",
    ".service.justice.gov.uk",
    ".github.com",
    ".githubusercontent.com",
    ".cache.amazonaws.com",
    ".veracode.com"
  ]
}
