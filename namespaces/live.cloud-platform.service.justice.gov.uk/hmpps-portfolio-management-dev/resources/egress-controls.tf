module "hmpps_egress_controls" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-egress-controls?ref=0.0.3"

  enable_envoy_setup     = true
  enable_egress_controls = true
  namespace              = var.namespace
  vpc_name               = var.vpc_name
  envoy_default_allowed_hosts_suffixes = [
    ".in.applicationinsights.azure.com",
    ".livediagnostics.monitor.azure.com",
    ".service.justice.gov.uk",
    ".github.com",
    ".githubusercontent.com",
    "justiceuk.sharepoint.com"
  ]
}
