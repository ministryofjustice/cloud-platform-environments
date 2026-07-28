module "hmpps_egress_controls" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-egress-controls?ref=0.0.7"

  enable_envoy_setup     = true
  enable_egress_controls = true

  namespace              = var.namespace
  vpc_name               = var.vpc_name

  envoy_extra_allowed_hosts_exact = [
    "justiceuk.sharepoint.com",
    "circleci.com",
    "monitoring-alerts-service.cloud-platform-monitoring-alerts"
  ]

  envoy_extra_allowed_hosts_suffixes = [
    ".github.com",
    ".githubusercontent.com",
    ".cache.amazonaws.com",
    ".veracode.com"
  ]
}
